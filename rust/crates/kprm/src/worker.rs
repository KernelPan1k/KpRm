//! Runs the (potentially slow, always blocking) engine calls on a background
//! thread so the UI stays responsive — a scan/removal pass takes seconds to
//! tens of seconds (see ../../README.md: ~13s for a full scan on the dev
//! machine), which would otherwise freeze every egui frame.

use std::sync::mpsc::{Receiver, Sender};

use kprm_catalog::Catalog;
use kprm_engine::orchestrator::{self, RunOptions};
use kprm_engine::paths::KnownDirs;
use kprm_engine::quarantine::QuarantineMode;
use kprm_engine::report::Report;
use kprm_engine::{backup, restore_point, system_settings, uac};

pub enum WorkerRequest {
    /// "Analyser": search-only scan across the whole catalog.
    Scan,
    /// "Exécuter": run the checked automatic-tab actions for real.
    RunAutomatic {
        backup_registry: bool,
        remove_tools: bool,
        restore_uac: bool,
        restore_settings: bool,
        remove_restore_points: bool,
        create_restore_point: bool,
        quarantine_mode: QuarantineMode,
    },
    /// "Supprimer la sélection": force-delete a fixed list of previously
    /// found `(tool, target)` pairs.
    RemoveSelected(Vec<(String, String)>),
    /// "Restaurer" (Extra Tools tab): schedules a previous registry
    /// backup's hive files to replace the live ones at next boot.
    RestoreRegistryBackup(kprm_engine::backup::AvailableBackup),
}

pub enum WorkerResponse {
    /// How many of the catalog's tools have been processed so far, out of
    /// how many total — sent between tools during a scan or a real
    /// "Supprimer les outils" pass (by far the slowest, most numerous
    /// step), so the UI can show real progress instead of just a spinner.
    Progress {
        current: usize,
        total: usize,
    },
    Done(Report),
    Failed(String),
}

/// Spawns the worker thread and returns the channel to send it requests on.
/// Every [`WorkerResponse`] — zero or more [`WorkerResponse::Progress`]
/// followed by exactly one [`WorkerResponse::Done`]/[`WorkerResponse::Failed`]
/// — is sent on `response_tx`, which the caller polls from the UI thread.
pub fn spawn(response_tx: Sender<WorkerResponse>) -> Sender<WorkerRequest> {
    let (request_tx, request_rx): (Sender<WorkerRequest>, Receiver<WorkerRequest>) =
        std::sync::mpsc::channel();

    std::thread::spawn(move || {
        for request in request_rx {
            handle(request, &response_tx);
        }
    });

    request_tx
}

fn handle(request: WorkerRequest, response_tx: &Sender<WorkerResponse>) {
    let catalog = match Catalog::embedded() {
        Ok(c) => c,
        Err(errors) => {
            let _ = response_tx.send(WorkerResponse::Failed(format!(
                "Catalogue invalide ({} erreur(s)) : {}",
                errors.len(),
                errors.first().map(|e| e.to_string()).unwrap_or_default()
            )));
            return;
        }
    };

    let dirs = kprm_windows::EnvKnownDirs::detect();
    let mut fs = kprm_windows::WinFileSystem;
    let mut registry = kprm_windows::WinRegistry;
    let mut processes = kprm_windows::WinProcessManager;
    let mut commands = kprm_windows::RealCommandRunner;
    let is_64bit_os = kprm_windows::is_64bit_os();

    match request {
        WorkerRequest::Scan => {
            let options = RunOptions {
                quarantine_mode: QuarantineMode::Keep,
                search_only: true,
                is_64bit_os,
            };
            let report = run_tools_with_progress(
                &catalog,
                &mut fs,
                &mut registry,
                &mut processes,
                &mut commands,
                &dirs,
                &options,
                response_tx,
            );
            let _ = response_tx.send(WorkerResponse::Done(report));
        }

        WorkerRequest::RunAutomatic {
            backup_registry,
            remove_tools,
            restore_uac,
            restore_settings,
            remove_restore_points,
            create_restore_point,
            quarantine_mode,
        } => {
            let mut report = Report::default();

            if backup_registry {
                let dir = backup::backup_dir(dirs.home_drive(), &kprm_windows::current_timestamp());
                if std::fs::create_dir_all(&dir).is_err() {
                    report.push(
                        "Sauvegarde du registre",
                        "task",
                        format!("créer le dossier {dir}"),
                        kprm_engine::report::EventResult::Failed("échec".to_string()),
                    );
                } else {
                    for result in backup::backup_registry(&mut registry, &dir) {
                        report.push(
                            "Sauvegarde du registre",
                            "task",
                            result.description,
                            if result.succeeded {
                                kprm_engine::report::EventResult::Ran
                            } else {
                                kprm_engine::report::EventResult::Failed("échec".to_string())
                            },
                        );
                    }
                }
            }

            if remove_restore_points {
                let result = restore_point::remove_all_restore_points(&mut commands);
                report.push(
                    "Points de restauration",
                    "task",
                    result.description,
                    if result.succeeded {
                        kprm_engine::report::EventResult::Ran
                    } else {
                        kprm_engine::report::EventResult::Failed("échec".to_string())
                    },
                );
            }

            if create_restore_point {
                for result in restore_point::create_restore_point(&mut commands, &mut registry) {
                    report.push(
                        "Points de restauration",
                        "task",
                        result.description,
                        if result.succeeded {
                            kprm_engine::report::EventResult::Ran
                        } else {
                            kprm_engine::report::EventResult::Failed("échec".to_string())
                        },
                    );
                }
            }

            if remove_restore_points || create_restore_point {
                let points = restore_point::list_restore_points(&mut commands);
                if points.is_empty() {
                    report.push(
                        "Points de restauration",
                        "restore_point",
                        "Aucun point de restauration trouvé",
                        kprm_engine::report::EventResult::Found,
                    );
                } else {
                    for point in points {
                        report.push(
                            "Points de restauration",
                            "restore_point",
                            format!(
                                "n°{} \"{}\" ({})",
                                point.sequence_number, point.description, point.created_at
                            ),
                            kprm_engine::report::EventResult::Found,
                        );
                    }
                }
            }

            if remove_tools {
                let options = RunOptions {
                    quarantine_mode,
                    search_only: false,
                    is_64bit_os,
                };
                report.merge(run_tools_with_progress(
                    &catalog,
                    &mut fs,
                    &mut registry,
                    &mut processes,
                    &mut commands,
                    &dirs,
                    &options,
                    response_tx,
                ));
            }

            if restore_uac {
                for result in uac::restore_uac(&mut registry, is_64bit_os) {
                    report.push(
                        "UAC",
                        "registry_key",
                        result.value_name,
                        if result.succeeded {
                            kprm_engine::report::EventResult::Removed
                        } else {
                            kprm_engine::report::EventResult::Failed("écriture échouée".to_string())
                        },
                    );
                }
            }

            if restore_settings {
                for result in system_settings::restore_defaults(&mut registry, &mut commands) {
                    report.push(
                        "Paramètres système",
                        "task",
                        result.description,
                        if result.succeeded {
                            kprm_engine::report::EventResult::Ran
                        } else {
                            kprm_engine::report::EventResult::Failed("échec".to_string())
                        },
                    );
                }
                system_settings::restart_explorer(&mut processes, &mut commands);
            }

            let deferred_items: Vec<(String, String)> = report
                .events
                .iter()
                .filter(|e| e.result == kprm_engine::report::EventResult::ScheduledIn7Days)
                .map(|e| (e.tool.clone(), e.target.clone()))
                .collect();

            let report_path =
                kprm_windows::write_and_open_report(&report, &dirs, &report_title(&dirs));

            if !deferred_items.is_empty() {
                let scheduled = kprm_windows::schedule_deferred_deletion(
                    &mut commands,
                    &dirs,
                    report_path.as_deref(),
                    &deferred_items,
                );
                // Silent on success, matching the original's own
                // SetDeleteQuarantinesIn7DaysIfNeeded (only logs on
                // failure) — the report is already written/opened by
                // this point, so a failure gets appended to it directly
                // rather than losing the information entirely.
                if !scheduled {
                    if let Some(path) = &report_path {
                        let _ = std::fs::OpenOptions::new()
                            .append(true)
                            .open(path)
                            .and_then(|mut file| {
                                use std::io::Write as _;
                                file.write_all(
                                    "\r\n- Erreurs -\r\n    [X] Échec de la planification de \
                                     la suppression différée (7 jours)\r\n"
                                        .as_bytes(),
                                )
                            });
                    }
                }
            }

            // Confirmed explicitly with the user before adding this: the
            // original deletes itself after a successful automatic run
            // (spec §2.2/§2.3) — a delayed `del` via `cmd.exe`, or folded
            // into the restart-on-reboot cleanup if one is pending.
            kprm_windows::schedule_self_deletion(report.needs_restart());

            let _ = response_tx.send(WorkerResponse::Done(report));
        }

        WorkerRequest::RemoveSelected(targets) => {
            let report = orchestrator::remove_selected_targets(
                &targets,
                &mut fs,
                &mut registry,
                &mut processes,
            );
            kprm_windows::write_and_open_report(&report, &dirs, &report_title(&dirs));
            kprm_windows::schedule_self_deletion(report.needs_restart());
            let _ = response_tx.send(WorkerResponse::Done(report));
        }

        WorkerRequest::RestoreRegistryBackup(backup) => {
            let targets = backup::restore_plan(&backup, &dirs);
            let outcomes = kprm_windows::schedule_registry_restore(&targets);

            let mut report = Report::default();
            for outcome in outcomes {
                report.push(
                    "Restauration du registre",
                    "registry_restore",
                    outcome.description,
                    if outcome.scheduled {
                        kprm_engine::report::EventResult::ScheduledOnReboot
                    } else {
                        kprm_engine::report::EventResult::Failed(
                            "fichier de sauvegarde introuvable, ou échec de la planification"
                                .to_string(),
                        )
                    },
                );
            }
            // A technician restoring a client's registry wants a paper
            // trail like any other real action — but this never triggers
            // schedule_self_deletion(), unlike RunAutomatic/RemoveSelected:
            // that behavior is specific to an actual cleanup run, and this
            // is a new, unrelated administrative feature.
            kprm_windows::write_and_open_report(&report, &dirs, &report_title(&dirs));
            let _ = response_tx.send(WorkerResponse::Done(report));
        }
    }
}

/// Runs every tool in `catalog`, sending a [`WorkerResponse::Progress`]
/// after each one — the same overall effect as
/// `orchestrator::run_tool_actions`, just with progress reporting woven
/// through the loop instead of only returning a result at the very end.
#[allow(clippy::too_many_arguments)]
fn run_tools_with_progress(
    catalog: &Catalog,
    fs: &mut dyn kprm_engine::ports::FileSystem,
    registry: &mut dyn kprm_engine::ports::Registry,
    processes: &mut dyn kprm_engine::ports::ProcessManager,
    commands: &mut dyn kprm_engine::ports::CommandRunner,
    dirs: &dyn KnownDirs,
    options: &RunOptions,
    response_tx: &Sender<WorkerResponse>,
) -> Report {
    let mut report = Report::default();
    let tools = catalog.tools();
    let total = tools.len();
    for (index, tool) in tools.iter().enumerate() {
        orchestrator::run_tool(
            tool,
            fs,
            registry,
            processes,
            commands,
            dirs,
            options,
            &mut report,
        );
        let _ = response_tx.send(WorkerResponse::Progress {
            current: index + 1,
            total,
        });
    }
    report
}

fn report_title(dirs: &kprm_windows::EnvKnownDirs) -> Vec<String> {
    let mut title = vec![
        format!(
            "# KpRm v{} — rapport du {}",
            env!("CARGO_PKG_VERSION"),
            kprm_windows::current_timestamp()
        ),
        "# https://github.com/KernelPan1k/KpRm".to_string(),
    ];
    title.extend(kprm_windows::collect_system_info(dirs).to_lines());
    title
}
