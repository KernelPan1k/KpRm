//! Runs the (potentially slow, always blocking) engine calls on a background
//! thread so the UI stays responsive — a scan/removal pass takes seconds to
//! tens of seconds (see ../../README.md: ~13s for a full scan on the dev
//! machine), which would otherwise freeze every egui frame.

use std::sync::mpsc::{Receiver, Sender};

use kprm_catalog::Catalog;
use kprm_engine::orchestrator::{self, RunOptions};
use kprm_engine::quarantine::QuarantineMode;
use kprm_engine::report::Report;
use kprm_engine::{restore_point, system_settings, uac};

pub enum WorkerRequest {
    /// "Analyser": search-only scan across the whole catalog.
    Scan,
    /// "Exécuter": run the checked automatic-tab actions for real.
    RunAutomatic {
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
}

pub enum WorkerResponse {
    Done(Report),
    Failed(String),
}

/// Spawns the worker thread and returns the channel to send it requests on;
/// `on_response` is called (from the worker thread) with each result — the
/// caller is expected to forward it into a channel the UI thread polls, or
/// otherwise trigger a repaint.
pub fn spawn(response_tx: Sender<WorkerResponse>) -> Sender<WorkerRequest> {
    let (request_tx, request_rx): (Sender<WorkerRequest>, Receiver<WorkerRequest>) =
        std::sync::mpsc::channel();

    std::thread::spawn(move || {
        for request in request_rx {
            let response = handle(request);
            if response_tx.send(response).is_err() {
                break;
            }
        }
    });

    request_tx
}

fn handle(request: WorkerRequest) -> WorkerResponse {
    let catalog = match Catalog::embedded() {
        Ok(c) => c,
        Err(errors) => {
            return WorkerResponse::Failed(format!(
                "Catalogue invalide ({} erreur(s)) : {}",
                errors.len(),
                errors.first().map(|e| e.to_string()).unwrap_or_default()
            ))
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
            let report = orchestrator::run_tool_actions(
                &catalog,
                &mut fs,
                &mut registry,
                &mut processes,
                &mut commands,
                &dirs,
                &options,
            );
            WorkerResponse::Done(report)
        }

        WorkerRequest::RunAutomatic {
            remove_tools,
            restore_uac,
            restore_settings,
            remove_restore_points,
            create_restore_point,
            quarantine_mode,
        } => {
            let mut report = Report::default();

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
                for result in restore_point::create_restore_point(&mut commands) {
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
                report.merge(orchestrator::run_tool_actions(
                    &catalog,
                    &mut fs,
                    &mut registry,
                    &mut processes,
                    &mut commands,
                    &dirs,
                    &options,
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

            kprm_windows::write_and_open_report(&report, &dirs, &report_title(&dirs));
            WorkerResponse::Done(report)
        }

        WorkerRequest::RemoveSelected(targets) => {
            let report = orchestrator::remove_selected_targets(&targets, &mut fs, &mut registry);
            kprm_windows::write_and_open_report(&report, &dirs, &report_title(&dirs));
            WorkerResponse::Done(report)
        }
    }
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
