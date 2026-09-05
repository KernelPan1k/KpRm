//! Ties the catalog, the pure decision logic (whitelist/quarantine/matcher),
//! and the [`crate::ports`] traits together: this is the Rust equivalent of
//! `RunRemoveTools`/`KpRemover` in `src/kp_includes/functions/functions.au3`,
//! made unit-testable against [`crate::fakes`] instead of a real machine.
//! See docs/RUST-REWRITE-SPEC.md §2.6 and §5.1.
//!
//! Unlike the original, this module never mutates a hidden global
//! `$bSearchOnly` flag read deep inside each removal function — [`RunOptions`]
//! is threaded explicitly, so "scan" and "remove" are the exact same code
//! path with one boolean flipped (docs/RUST-REWRITE-SPEC.md §10, point 2).

use kprm_catalog::{
    Action, Catalog, CleanDirectoryAction, EntryKind, FileAction, FileLikeAction, FolderAction,
    ProcessAction, RegistryKeyAction, SearchRegistryKeyAction, SoftwareKeyAction, TaskAction,
    UninstallAction,
};
use regex::Regex;

use crate::matcher::{has_exe_or_com_extension, match_entry, CandidateEntry, FileRule};
use crate::paths::{resolve_path_macro, KnownDirs};
use crate::ports::{CommandRunner, FileSystem, ProcessManager, Registry, Removal};
use crate::quarantine::{self, QuarantineMode};
use crate::registry as reg_fmt;
use crate::report::{EventResult, Report};
use crate::whitelist;

pub struct RunOptions {
    pub quarantine_mode: QuarantineMode,
    /// `true` = "Analyser" (find and report only, touch nothing); `false` =
    /// "Exécuter"/"Supprimer" (act for real).
    pub search_only: bool,
    pub is_64bit_os: bool,
}

/// Runs every action of every tool in `catalog` against the given ports.
/// Directory-like actions are walked one tool-action at a time rather than
/// batched per directory across all tools like the original engine did for
/// performance — a reasonable v1 simplification (see docs/RUST-REWRITE-SPEC.md
/// §5.1); correctness is identical, only the number of directory listings
/// differs.
#[allow(clippy::too_many_arguments)]
pub fn run_tool_actions(
    catalog: &Catalog,
    fs: &mut dyn FileSystem,
    registry: &mut dyn Registry,
    processes: &mut dyn ProcessManager,
    commands: &mut dyn CommandRunner,
    dirs: &dyn KnownDirs,
    options: &RunOptions,
) -> Report {
    let mut report = Report::default();
    for tool in catalog.tools() {
        run_tool(
            tool,
            fs,
            registry,
            processes,
            commands,
            dirs,
            options,
            &mut report,
        );
    }
    report
}

/// Runs every action of a single `tool`, appending results into `report` —
/// the per-tool unit [`run_tool_actions`] loops over the whole catalog
/// with. Exposed separately so a caller (the GUI's worker thread) can
/// report progress between tools instead of only getting one result at
/// the very end of a ~200-tool, several-second pass.
#[allow(clippy::too_many_arguments)]
pub fn run_tool(
    tool: &kprm_catalog::Tool,
    fs: &mut dyn FileSystem,
    registry: &mut dyn Registry,
    processes: &mut dyn ProcessManager,
    commands: &mut dyn CommandRunner,
    dirs: &dyn KnownDirs,
    options: &RunOptions,
    report: &mut Report,
) {
    for action in &tool.actions {
        handle_action(
            &tool.name, action, fs, registry, processes, commands, dirs, options, report,
        );
    }
}

/// Force-deletes a fixed list of previously-found `(tool, target)` pairs —
/// the Rust equivalent of `RemoveAllSelectedLineSearch`, used by the
/// "Analyse personnalisée" tab's "Supprimer la sélection" button. Unlike
/// [`run_tool_actions`], this never consults the catalog or quarantine
/// rules: every target the caller passes in is deleted unconditionally,
/// exactly like the original's custom-selection removal. A target starting
/// with `HK` is treated as a registry key; otherwise its real kind (file or
/// folder) decides how it's removed.
///
/// Closes any running process whose executable is one of the selected
/// targets first — mirrors the original closing the processes associated
/// with the checked rows before deleting them; without this, a selected
/// target that's currently a running `.exe` would fail to delete as locked.
pub fn remove_selected_targets(
    targets: &[(String, String)],
    fs: &mut dyn FileSystem,
    registry: &mut dyn Registry,
    processes: &mut dyn ProcessManager,
) -> Report {
    let mut report = Report::default();

    let running = processes.list();
    for (_, target) in targets {
        for process in running.iter().filter(|p| {
            p.exe_path
                .as_deref()
                .is_some_and(|p| p.eq_ignore_ascii_case(target))
        }) {
            processes.kill(process.pid);
        }
    }

    for (tool, target) in targets {
        if target.starts_with("HK") {
            let result = if registry.delete_key(target) {
                EventResult::Removed
            } else {
                EventResult::Failed("registry key could not be deleted".to_string())
            };
            report.push(tool.clone(), "registry_key", target.clone(), result);
            continue;
        }

        match fs.kind(target) {
            Some(EntryKind::File) => {
                let result = removal_to_event(fs.remove_file(target));
                report.push(tool.clone(), "file", target.clone(), result);
            }
            Some(EntryKind::Folder) => {
                let result = removal_to_event(fs.remove_dir(target));
                report.push(tool.clone(), "folder", target.clone(), result);
            }
            None => {}
        }
    }

    report
}

fn removal_to_event(removal: Removal) -> EventResult {
    match removal {
        Removal::Deleted => EventResult::Removed,
        Removal::ScheduledOnReboot => EventResult::ScheduledOnReboot,
        Removal::NotFound => EventResult::Failed("target no longer exists".to_string()),
    }
}

#[allow(clippy::too_many_arguments)]
fn handle_action(
    tool: &str,
    action: &Action,
    fs: &mut dyn FileSystem,
    registry: &mut dyn Registry,
    processes: &mut dyn ProcessManager,
    commands: &mut dyn CommandRunner,
    dirs: &dyn KnownDirs,
    options: &RunOptions,
    report: &mut Report,
) {
    match action {
        Action::Process(a) => handle_process(tool, a, fs, processes, options, report),
        Action::Desktop(a) => {
            let root = dirs.desktop().to_string();
            handle_file_like(tool, "desktop", a, &root, 3, fs, options, report);
        }
        Action::DesktopCommon(a) => {
            let root = dirs.desktop_common().to_string();
            handle_file_like(tool, "desktop_common", a, &root, 1, fs, options, report);
        }
        Action::Download(a) => {
            let root = format!("{}\\Downloads", dirs.user_profile());
            handle_file_like(tool, "download", a, &root, 3, fs, options, report);
        }
        Action::ProgramFiles(a) => {
            for root in program_files_roots(fs, dirs) {
                handle_file_like(tool, "program_files", a, &root, 1, fs, options, report);
            }
        }
        Action::HomeDrive(a) => {
            let root = dirs.home_drive().to_string();
            handle_file_like(tool, "home_drive", a, &root, 1, fs, options, report);
        }
        Action::AppData(a) => {
            let root = dirs.app_data().to_string();
            handle_file_like(tool, "app_data", a, &root, 1, fs, options, report);
        }
        Action::AppDataCommon(a) => {
            let root = dirs.app_data_common().to_string();
            handle_file_like(tool, "app_data_common", a, &root, 1, fs, options, report);
        }
        Action::AppDataLocal(a) => {
            let root = dirs.local_app_data().to_string();
            handle_file_like(tool, "app_data_local", a, &root, 1, fs, options, report);
        }
        Action::WindowsFolder(a) => {
            let root = dirs.windows_dir().to_string();
            handle_file_like(tool, "windows_folder", a, &root, 1, fs, options, report);
        }
        Action::StartMenu(a) => {
            let root = format!(
                "{}\\Microsoft\\Windows\\Start Menu\\Programs",
                dirs.app_data_common()
            );
            handle_file_like(tool, "start_menu", a, &root, 1, fs, options, report);
        }
        Action::UserStartMenu(a) => {
            let root = format!(
                "{}\\Microsoft\\Windows\\Start Menu\\Programs",
                dirs.app_data()
            );
            handle_file_like(tool, "user_start_menu", a, &root, 1, fs, options, report);
        }
        Action::SoftwareKey(a) => {
            handle_software_key(tool, a, registry, options.is_64bit_os, options, report);
        }
        Action::RegistryKey(a) => {
            handle_registry_key(tool, a, registry, options.is_64bit_os, options, report);
        }
        Action::SearchRegistryKey(a) => {
            handle_search_registry_key(tool, a, registry, options.is_64bit_os, options, report);
        }
        Action::CleanDirectory(a) => handle_clean_directory(tool, a, fs, dirs, options, report),
        Action::File(a) => handle_file(tool, a, fs, dirs, options, report),
        Action::Folder(a) => handle_folder(tool, a, fs, dirs, options, report),
        Action::Task(a) => handle_task(tool, a, commands, options, report),
        Action::Uninstall(a) => handle_uninstall(tool, a, fs, commands, dirs, options, report),
    }
}

fn compiled(pattern: &str) -> Regex {
    Regex::new(pattern).expect("catalog regex was validated by kprm_catalog::Catalog::validate")
}

fn optional_compiled(pattern: &str) -> Option<Regex> {
    if pattern.is_empty() {
        None
    } else {
        Some(compiled(pattern))
    }
}

fn basename(path: &str) -> &str {
    path.rsplit(['\\', '/']).next().unwrap_or(path)
}

fn program_files_roots(fs: &dyn FileSystem, dirs: &dyn KnownDirs) -> Vec<String> {
    [
        format!("{}\\Program Files", dirs.home_drive()),
        format!("{}\\Program Files (x86)", dirs.home_drive()),
        format!("{}\\Program Files(x86)", dirs.home_drive()),
    ]
    .into_iter()
    .filter(|p| fs.kind(p) == Some(EntryKind::Folder))
    .collect()
}

#[allow(clippy::too_many_arguments)]
fn apply_removal(
    tool: &str,
    action_type: &'static str,
    target: &str,
    kind: EntryKind,
    quarantine_flag: bool,
    fs: &mut dyn FileSystem,
    options: &RunOptions,
    report: &mut Report,
) {
    if options.search_only {
        report.push(tool, action_type, target, EventResult::Found);
        return;
    }

    match quarantine::decide(quarantine_flag, options.quarantine_mode) {
        quarantine::QuarantineDecision::Keep => {
            report.push(tool, action_type, target, EventResult::Kept)
        }
        quarantine::QuarantineDecision::ScheduleIn7Days => {
            report.push(tool, action_type, target, EventResult::ScheduledIn7Days)
        }
        quarantine::QuarantineDecision::DeleteNow => {
            let removal = match kind {
                EntryKind::File => fs.remove_file(target),
                EntryKind::Folder => fs.remove_dir(target),
            };
            let result = match removal {
                Removal::Deleted => EventResult::Removed,
                Removal::ScheduledOnReboot => EventResult::ScheduledOnReboot,
                Removal::NotFound => return,
            };
            report.push(tool, action_type, target, result);
        }
    }
}

fn apply_registry_removal(
    tool: &str,
    action_type: &'static str,
    key: &str,
    registry: &mut dyn Registry,
    options: &RunOptions,
    report: &mut Report,
) {
    if options.search_only {
        report.push(tool, action_type, key, EventResult::Found);
        return;
    }
    if registry.delete_key(key) {
        report.push(tool, action_type, key, EventResult::Removed);
    }
}

fn handle_process(
    tool: &str,
    action: &ProcessAction,
    fs: &mut dyn FileSystem,
    processes: &mut dyn ProcessManager,
    options: &RunOptions,
    report: &mut Report,
) {
    let pattern = compiled(&action.pattern);
    let company = optional_compiled(&action.company_name);

    for p in processes.list() {
        if whitelist::is_process_whitelisted(&p.name) {
            continue;
        }
        if !pattern.is_match(&p.name) {
            continue;
        }
        if let Some(company_pattern) = &company {
            let matches_company = p
                .exe_path
                .as_deref()
                .and_then(|path| fs.company_name(path))
                .is_some_and(|name| company_pattern.is_match(&name));
            if !matches_company {
                continue;
            }
        }

        let target = p.exe_path.clone().unwrap_or_else(|| p.name.clone());
        if options.search_only {
            report.push(tool, "process", target, EventResult::Found);
        } else {
            processes.kill(p.pid);
            report.push(tool, "process", target, EventResult::Removed);
        }
    }
}

/// Walks `root` and hands each child to [`crate::matcher::match_entry`]
/// against `action`'s single rule — reusing the already-tested whitelist +
/// company-name-filter semantics instead of re-implementing them here.
#[allow(clippy::too_many_arguments)]
fn handle_file_like(
    tool: &str,
    action_type: &'static str,
    action: &FileLikeAction,
    root: &str,
    depth: u32,
    fs: &mut dyn FileSystem,
    options: &RunOptions,
    report: &mut Report,
) {
    let pattern = compiled(&action.pattern);
    let company = optional_compiled(&action.company_name);
    let rules = [FileRule {
        tool,
        pattern: &pattern,
        company_name: company.as_ref(),
        kind: action.kind,
        quarantine: action.quarantine,
    }];

    for child in fs.list_dir(root, depth) {
        let Some(kind) = fs.kind(&child) else {
            continue;
        };
        let file_name = basename(&child).to_string();

        // Company info is only ever consulted for `.exe`/`.com` files with a
        // company filter — read it lazily to avoid needless version-info
        // reads on every other file.
        let company_name =
            if kind == EntryKind::File && company.is_some() && has_exe_or_com_extension(&file_name)
            {
                fs.company_name(&child)
            } else {
                None
            };

        let candidate = CandidateEntry {
            full_path: &child,
            file_name: &file_name,
            kind,
            company_name: company_name.as_deref(),
        };

        if let Some(m) = match_entry(&candidate, &rules).first() {
            apply_removal(
                tool,
                action_type,
                &child,
                kind,
                m.quarantine,
                fs,
                options,
                report,
            );
        }
    }
}

fn handle_software_key(
    tool: &str,
    action: &SoftwareKeyAction,
    registry: &mut dyn Registry,
    is_64bit_os: bool,
    options: &RunOptions,
    report: &mut Report,
) {
    let pattern = compiled(&action.pattern);
    let suffix = reg_fmt::suffix_key(is_64bit_os);
    for hive in ["HKCU", "HKLM"] {
        let base = format!("{hive}{suffix}\\SOFTWARE");
        for subkey in registry.enum_subkeys(&base) {
            if pattern.is_match(basename(&subkey)) {
                apply_registry_removal(tool, "software_key", &subkey, registry, options, report);
            }
        }
    }
}

fn handle_registry_key(
    tool: &str,
    action: &RegistryKeyAction,
    registry: &mut dyn Registry,
    is_64bit_os: bool,
    options: &RunOptions,
    report: &mut Report,
) {
    let key = reg_fmt::format_for_use(&action.key, is_64bit_os);
    if !registry.has_any_value(&key) {
        return;
    }
    apply_registry_removal(tool, "registry_key", &key, registry, options, report);
}

fn handle_search_registry_key(
    tool: &str,
    action: &SearchRegistryKeyAction,
    registry: &mut dyn Registry,
    is_64bit_os: bool,
    options: &RunOptions,
    report: &mut Report,
) {
    let key = reg_fmt::format_for_use(&action.key, is_64bit_os);
    let pattern = compiled(&action.pattern);
    for subkey in registry.enum_subkeys(&key) {
        if let Some(value) = registry.read_value(&subkey, &action.value) {
            if pattern.is_match(&value) {
                apply_registry_removal(
                    tool,
                    "search_registry_key",
                    &subkey,
                    registry,
                    options,
                    report,
                );
            }
        }
    }
}

fn handle_clean_directory(
    tool: &str,
    action: &CleanDirectoryAction,
    fs: &mut dyn FileSystem,
    dirs: &dyn KnownDirs,
    options: &RunOptions,
    report: &mut Report,
) {
    let path = resolve_path_macro(&action.path, dirs);
    if fs.kind(&path) != Some(EntryKind::Folder) {
        return;
    }
    let company = optional_compiled(&action.company_name);

    for child in fs.list_dir(&path, 1) {
        if fs.kind(&child) != Some(EntryKind::File) {
            continue;
        }
        if whitelist::is_file_whitelisted(&child) {
            continue;
        }
        let file_name = basename(&child).to_string();
        if has_exe_or_com_extension(&file_name) {
            if let Some(company_pattern) = &company {
                let matches_company = fs
                    .company_name(&child)
                    .is_some_and(|c| company_pattern.is_match(&c));
                if !matches_company {
                    continue;
                }
            }
        }
        apply_removal(
            tool,
            "clean_directory",
            &child,
            EntryKind::File,
            action.quarantine,
            fs,
            options,
            report,
        );
    }
}

fn handle_file(
    tool: &str,
    action: &FileAction,
    fs: &mut dyn FileSystem,
    dirs: &dyn KnownDirs,
    options: &RunOptions,
    report: &mut Report,
) {
    let path = resolve_path_macro(&action.path, dirs);
    if fs.kind(&path) != Some(EntryKind::File) {
        return;
    }
    if whitelist::is_file_whitelisted(&path) {
        return;
    }
    let file_name = basename(&path).to_string();
    if has_exe_or_com_extension(&file_name) {
        if let Some(company_pattern) = optional_compiled(&action.company_name) {
            let matches_company = fs
                .company_name(&path)
                .is_some_and(|c| company_pattern.is_match(&c));
            if !matches_company {
                return;
            }
        }
    }
    apply_removal(
        tool,
        "file",
        &path,
        EntryKind::File,
        false,
        fs,
        options,
        report,
    );
}

fn handle_folder(
    tool: &str,
    action: &FolderAction,
    fs: &mut dyn FileSystem,
    dirs: &dyn KnownDirs,
    options: &RunOptions,
    report: &mut Report,
) {
    let path = resolve_path_macro(&action.path, dirs);
    if fs.kind(&path) != Some(EntryKind::Folder) {
        return;
    }
    apply_removal(
        tool,
        "folder",
        &path,
        EntryKind::Folder,
        action.quarantine,
        fs,
        options,
        report,
    );
}

fn handle_task(
    tool: &str,
    action: &TaskAction,
    commands: &mut dyn CommandRunner,
    options: &RunOptions,
    report: &mut Report,
) {
    if options.search_only {
        report.push(tool, "task", action.name.clone(), EventResult::Found);
        return;
    }
    let ok = commands.run("schtasks.exe", &["/delete", "/tn", &action.name, "/f"]);
    report.push(
        tool,
        "task",
        action.name.clone(),
        if ok {
            EventResult::Removed
        } else {
            EventResult::Failed("schtasks.exe failed".to_string())
        },
    );
}

fn handle_uninstall(
    tool: &str,
    action: &UninstallAction,
    fs: &mut dyn FileSystem,
    commands: &mut dyn CommandRunner,
    dirs: &dyn KnownDirs,
    options: &RunOptions,
    report: &mut Report,
) {
    let folder_pattern = compiled(&action.folder);
    let file_pattern = compiled(&action.uninstaller);

    for root in program_files_roots(fs, dirs) {
        for folder in fs.list_dir(&root, 1) {
            if fs.kind(&folder) != Some(EntryKind::Folder) {
                continue;
            }
            if !folder_pattern.is_match(basename(&folder)) {
                continue;
            }
            for file in fs.list_dir(&folder, 1) {
                if fs.kind(&file) != Some(EntryKind::File) {
                    continue;
                }
                if !file_pattern.is_match(basename(&file)) {
                    continue;
                }
                if options.search_only {
                    report.push(tool, "uninstall", folder.clone(), EventResult::Found);
                } else {
                    let ok = commands.run(&file, &[]);
                    report.push(
                        tool,
                        "uninstall",
                        file.clone(),
                        if ok {
                            EventResult::Ran
                        } else {
                            EventResult::Failed("uninstaller exited with an error".to_string())
                        },
                    );
                }
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::fakes::{
        FakeCommandRunner, FakeFileSystem, FakeKnownDirs, FakeProcessManager, FakeRegistry,
    };

    fn default_options() -> RunOptions {
        RunOptions {
            quarantine_mode: QuarantineMode::Keep,
            search_only: false,
            is_64bit_os: true,
        }
    }

    // `Catalog`'s fields are private (only constructible via validated
    // loaders), so tests call the handler dispatch directly through a tiny
    // single-tool harness instead of building a real `Catalog`.
    #[allow(clippy::too_many_arguments)]
    fn run_single(
        tool_name: &str,
        action: Action,
        fs: &mut dyn FileSystem,
        registry: &mut dyn Registry,
        processes: &mut dyn ProcessManager,
        commands: &mut dyn CommandRunner,
        dirs: &dyn KnownDirs,
        options: &RunOptions,
    ) -> Report {
        let mut report = Report::default();
        handle_action(
            tool_name,
            &action,
            fs,
            registry,
            processes,
            commands,
            dirs,
            options,
            &mut report,
        );
        report
    }

    #[test]
    fn process_action_kills_a_matching_process_and_reports_it() {
        let mut fs = FakeFileSystem::new();
        let mut registry = FakeRegistry::new();
        let mut processes = FakeProcessManager::new();
        processes.add(
            42,
            "AdwCleaner.exe",
            Some(r"C:\Users\bob\Desktop\AdwCleaner.exe"),
        );
        let mut commands = FakeCommandRunner::new();
        let dirs = FakeKnownDirs::default();

        let action = Action::Process(ProcessAction {
            pattern: r"(?i)^AdwCleaner\.exe$".to_string(),
            company_name: String::new(),
            force: false,
        });

        let report = run_single(
            "AdwCleaner",
            action,
            &mut fs,
            &mut registry,
            &mut processes,
            &mut commands,
            &dirs,
            &default_options(),
        );

        assert_eq!(report.events.len(), 1);
        assert_eq!(report.events[0].result, EventResult::Removed);
        assert!(processes.killed.contains(&42));
    }

    #[test]
    fn process_action_never_kills_a_whitelisted_process() {
        let mut fs = FakeFileSystem::new();
        let mut registry = FakeRegistry::new();
        let mut processes = FakeProcessManager::new();
        processes.add(7, "sftvsa.exe", None);
        let mut commands = FakeCommandRunner::new();
        let dirs = FakeKnownDirs::default();

        let action = Action::Process(ProcessAction {
            pattern: r"(?i)^sftvsa\.exe$".to_string(),
            company_name: String::new(),
            force: false,
        });

        let report = run_single(
            "SomeTool",
            action,
            &mut fs,
            &mut registry,
            &mut processes,
            &mut commands,
            &dirs,
            &default_options(),
        );

        assert!(report.events.is_empty());
        assert!(!processes.killed.contains(&7));
    }

    #[test]
    fn desktop_action_deletes_a_matching_file() {
        let mut fs = FakeFileSystem::new();
        fs.add_file(
            r"C:\Users\bob\Desktop\AdwCleaner.exe",
            Some("Malwarebytes Inc."),
        );
        let mut registry = FakeRegistry::new();
        let mut processes = FakeProcessManager::new();
        let mut commands = FakeCommandRunner::new();
        let dirs = FakeKnownDirs::default();

        let action = Action::Desktop(FileLikeAction {
            pattern: r"(?i)^AdwCleaner\.exe$".to_string(),
            company_name: r"(?i)^Malwarebytes".to_string(),
            kind: EntryKind::File,
            quarantine: false,
        });

        let report = run_single(
            "AdwCleaner",
            action,
            &mut fs,
            &mut registry,
            &mut processes,
            &mut commands,
            &dirs,
            &default_options(),
        );

        assert_eq!(report.events.len(), 1);
        assert_eq!(report.events[0].result, EventResult::Removed);
        assert!(fs
            .removed
            .contains(&r"C:\Users\bob\Desktop\AdwCleaner.exe".to_string()));
    }

    #[test]
    fn search_only_mode_finds_without_deleting() {
        let mut fs = FakeFileSystem::new();
        fs.add_file(r"C:\Users\bob\Desktop\AdwCleaner.exe", None);
        let mut registry = FakeRegistry::new();
        let mut processes = FakeProcessManager::new();
        let mut commands = FakeCommandRunner::new();
        let dirs = FakeKnownDirs::default();

        let action = Action::Desktop(FileLikeAction {
            pattern: r"(?i)^AdwCleaner\.exe$".to_string(),
            company_name: String::new(),
            kind: EntryKind::File,
            quarantine: false,
        });

        let mut options = default_options();
        options.search_only = true;

        let report = run_single(
            "AdwCleaner",
            action,
            &mut fs,
            &mut registry,
            &mut processes,
            &mut commands,
            &dirs,
            &options,
        );

        assert_eq!(report.events.len(), 1);
        assert_eq!(report.events[0].result, EventResult::Found);
        assert!(
            fs.removed.is_empty(),
            "search-only must never delete anything"
        );
    }

    #[test]
    fn home_drive_folder_kept_when_quarantine_mode_is_keep() {
        let mut fs = FakeFileSystem::new();
        fs.add_folder(r"C:\AdwCleaner");
        let mut registry = FakeRegistry::new();
        let mut processes = FakeProcessManager::new();
        let mut commands = FakeCommandRunner::new();
        let dirs = FakeKnownDirs::default();

        let action = Action::HomeDrive(FileLikeAction {
            pattern: r"(?i)^AdwCleaner$".to_string(),
            company_name: String::new(),
            kind: EntryKind::Folder,
            quarantine: true,
        });

        let report = run_single(
            "AdwCleaner",
            action,
            &mut fs,
            &mut registry,
            &mut processes,
            &mut commands,
            &dirs,
            &default_options(),
        );

        assert_eq!(report.events[0].result, EventResult::Kept);
        assert!(fs.removed.is_empty());
    }

    #[test]
    fn home_drive_folder_scheduled_in_7_days_when_requested() {
        let mut fs = FakeFileSystem::new();
        fs.add_folder(r"C:\AdwCleaner");
        let mut registry = FakeRegistry::new();
        let mut processes = FakeProcessManager::new();
        let mut commands = FakeCommandRunner::new();
        let dirs = FakeKnownDirs::default();

        let action = Action::HomeDrive(FileLikeAction {
            pattern: r"(?i)^AdwCleaner$".to_string(),
            company_name: String::new(),
            kind: EntryKind::Folder,
            quarantine: true,
        });

        let mut options = default_options();
        options.quarantine_mode = QuarantineMode::In7Days;

        let report = run_single(
            "AdwCleaner",
            action,
            &mut fs,
            &mut registry,
            &mut processes,
            &mut commands,
            &dirs,
            &options,
        );

        assert_eq!(report.events[0].result, EventResult::ScheduledIn7Days);
        assert!(fs.removed.is_empty());
    }

    #[test]
    fn locked_file_is_scheduled_on_reboot() {
        let mut fs = FakeFileSystem::new();
        fs.add_file(r"C:\Users\bob\Desktop\AdwCleaner.exe", None);
        fs.lock(r"C:\Users\bob\Desktop\AdwCleaner.exe");
        let mut registry = FakeRegistry::new();
        let mut processes = FakeProcessManager::new();
        let mut commands = FakeCommandRunner::new();
        let dirs = FakeKnownDirs::default();

        let action = Action::Desktop(FileLikeAction {
            pattern: r"(?i)^AdwCleaner\.exe$".to_string(),
            company_name: String::new(),
            kind: EntryKind::File,
            quarantine: false,
        });

        let report = run_single(
            "AdwCleaner",
            action,
            &mut fs,
            &mut registry,
            &mut processes,
            &mut commands,
            &dirs,
            &default_options(),
        );

        assert_eq!(report.events[0].result, EventResult::ScheduledOnReboot);
    }

    #[test]
    fn clean_directory_removes_every_file_inside() {
        let mut fs = FakeFileSystem::new();
        fs.add_folder(r"C:\ProgramData\ADiag\quarantine");
        fs.add_file(r"C:\ProgramData\ADiag\quarantine\a.dat", None);
        fs.add_file(r"C:\ProgramData\ADiag\quarantine\b.dat", None);
        let mut registry = FakeRegistry::new();
        let mut processes = FakeProcessManager::new();
        let mut commands = FakeCommandRunner::new();
        let dirs = FakeKnownDirs::default();

        let action = Action::CleanDirectory(CleanDirectoryAction {
            path: r"@AppDataCommonDir\ADiag\quarantine".to_string(),
            company_name: String::new(),
            quarantine: false,
        });

        let report = run_single(
            "AdliceDiag",
            action,
            &mut fs,
            &mut registry,
            &mut processes,
            &mut commands,
            &dirs,
            &default_options(),
        );

        assert_eq!(report.events.len(), 2);
        assert!(report
            .events
            .iter()
            .all(|e| e.result == EventResult::Removed));
    }

    #[test]
    fn registry_key_with_no_values_is_left_alone() {
        let mut fs = FakeFileSystem::new();
        let mut registry = FakeRegistry::new();
        registry.add_key(r"HKLM64\SYSTEM\CurrentControlSet\Enum\Root\LEGACY_ASWMBR");
        let mut processes = FakeProcessManager::new();
        let mut commands = FakeCommandRunner::new();
        let dirs = FakeKnownDirs::default();

        let action = Action::RegistryKey(RegistryKeyAction {
            key: r"HKLM\SYSTEM\CurrentControlSet\Enum\Root\LEGACY_ASWMBR".to_string(),
        });

        let report = run_single(
            "AswMBR",
            action,
            &mut fs,
            &mut registry,
            &mut processes,
            &mut commands,
            &dirs,
            &default_options(),
        );

        assert!(report.events.is_empty());
        assert!(!registry
            .deleted_keys
            .contains(&r"HKLM64\SYSTEM\CurrentControlSet\Enum\Root\LEGACY_ASWMBR".to_string()));
    }

    #[test]
    fn registry_key_with_values_is_deleted() {
        let mut fs = FakeFileSystem::new();
        let mut registry = FakeRegistry::new();
        registry.add_value(
            r"HKLM64\SYSTEM\CurrentControlSet\Enum\Root\LEGACY_ASWMBR",
            "Class",
            "LegacyDriver",
        );
        let mut processes = FakeProcessManager::new();
        let mut commands = FakeCommandRunner::new();
        let dirs = FakeKnownDirs::default();

        let action = Action::RegistryKey(RegistryKeyAction {
            key: r"HKLM\SYSTEM\CurrentControlSet\Enum\Root\LEGACY_ASWMBR".to_string(),
        });

        let report = run_single(
            "AswMBR",
            action,
            &mut fs,
            &mut registry,
            &mut processes,
            &mut commands,
            &dirs,
            &default_options(),
        );

        assert_eq!(report.events[0].result, EventResult::Removed);
        assert!(registry
            .deleted_keys
            .contains(&r"HKLM64\SYSTEM\CurrentControlSet\Enum\Root\LEGACY_ASWMBR".to_string()));
    }

    #[test]
    fn search_registry_key_matches_on_value_content_not_key_name() {
        let mut fs = FakeFileSystem::new();
        let mut registry = FakeRegistry::new();
        registry.add_value(
            r"HKLM64\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{SOME-GUID}",
            "DisplayName",
            "Fix-Purge 3.0",
        );
        let mut processes = FakeProcessManager::new();
        let mut commands = FakeCommandRunner::new();
        let dirs = FakeKnownDirs::default();

        let action = Action::SearchRegistryKey(SearchRegistryKeyAction {
            key: r"HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall".to_string(),
            pattern: r"(?i)^Fix\-Purge".to_string(),
            value: "DisplayName".to_string(),
        });

        let report = run_single(
            "FixPurge",
            action,
            &mut fs,
            &mut registry,
            &mut processes,
            &mut commands,
            &dirs,
            &default_options(),
        );

        assert_eq!(report.events[0].result, EventResult::Removed);
    }

    #[test]
    fn task_action_shells_out_to_schtasks() {
        let mut fs = FakeFileSystem::new();
        let mut registry = FakeRegistry::new();
        let mut processes = FakeProcessManager::new();
        let mut commands = FakeCommandRunner::new();
        let dirs = FakeKnownDirs::default();

        let action = Action::Task(TaskAction {
            name: "KpRm-quarantines\\demo".to_string(),
        });

        let report = run_single(
            "SomeTool",
            action,
            &mut fs,
            &mut registry,
            &mut processes,
            &mut commands,
            &dirs,
            &default_options(),
        );

        assert_eq!(report.events[0].result, EventResult::Removed);
        assert_eq!(commands.calls[0].0, "schtasks.exe");
        assert!(commands.calls[0]
            .1
            .contains(&"KpRm-quarantines\\demo".to_string()));
    }

    #[test]
    fn uninstall_action_runs_the_matching_uninstaller() {
        let mut fs = FakeFileSystem::new();
        fs.add_folder(r"C:\Program Files");
        fs.add_folder(r"C:\Program Files\SEAF");
        fs.add_file(r"C:\Program Files\SEAF\Un-SEAF.exe", None);
        let mut registry = FakeRegistry::new();
        let mut processes = FakeProcessManager::new();
        let mut commands = FakeCommandRunner::new();
        let dirs = FakeKnownDirs::default();

        let action = Action::Uninstall(UninstallAction {
            folder: r"(?i)^SEAF$".to_string(),
            uninstaller: r"(?i)^Un\-SEAF\.exe$".to_string(),
        });

        let report = run_single(
            "SEAF",
            action,
            &mut fs,
            &mut registry,
            &mut processes,
            &mut commands,
            &dirs,
            &default_options(),
        );

        assert_eq!(report.events[0].result, EventResult::Ran);
        assert_eq!(commands.calls[0].0, r"C:\Program Files\SEAF\Un-SEAF.exe");
    }

    #[test]
    fn remove_selected_targets_deletes_files_folders_and_registry_keys_unconditionally() {
        let mut fs = FakeFileSystem::new();
        fs.add_file(r"C:\FRST\FRST.txt", None);
        fs.add_folder(r"C:\_OTL");
        let mut registry = FakeRegistry::new();
        registry.add_value(r"HKCU\Software\Foo", "V", "1");
        let mut processes = FakeProcessManager::new();

        let targets = vec![
            ("FRST".to_string(), r"C:\FRST\FRST.txt".to_string()),
            ("OTL".to_string(), r"C:\_OTL".to_string()),
            ("Foo".to_string(), r"HKCU\Software\Foo".to_string()),
        ];

        let report = remove_selected_targets(&targets, &mut fs, &mut registry, &mut processes);

        assert_eq!(report.events.len(), 3);
        assert!(report
            .events
            .iter()
            .all(|e| e.result == EventResult::Removed));
        assert!(fs.removed.contains(&r"C:\FRST\FRST.txt".to_string()));
        assert!(fs.removed.contains(&r"C:\_OTL".to_string()));
        assert!(registry
            .deleted_keys
            .contains(&r"HKCU\Software\Foo".to_string()));
    }

    #[test]
    fn remove_selected_targets_skips_a_target_that_no_longer_exists() {
        let mut fs = FakeFileSystem::new();
        let mut registry = FakeRegistry::new();
        let mut processes = FakeProcessManager::new();

        let targets = vec![("Ghost".to_string(), r"C:\already\gone.txt".to_string())];
        let report = remove_selected_targets(&targets, &mut fs, &mut registry, &mut processes);

        assert!(report.events.is_empty());
    }

    #[test]
    fn remove_selected_targets_kills_a_running_process_matching_a_selected_target() {
        let mut fs = FakeFileSystem::new();
        fs.add_file(r"C:\FRST\FRST.exe", None);
        let mut registry = FakeRegistry::new();
        let mut processes = FakeProcessManager::new();
        processes.add(1234, "FRST.exe", Some(r"C:\FRST\FRST.exe"));
        processes.add(999, "notepad.exe", Some(r"C:\Windows\notepad.exe"));

        let targets = vec![("FRST".to_string(), r"C:\FRST\FRST.exe".to_string())];
        remove_selected_targets(&targets, &mut fs, &mut registry, &mut processes);

        assert!(processes.killed.contains(&1234));
        assert!(!processes.killed.contains(&999));
    }
}
