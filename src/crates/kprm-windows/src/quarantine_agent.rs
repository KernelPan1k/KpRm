//! Real scheduling and headless execution of the "Dans 7 jours" deferred
//! quarantine deletion — the counterpart of the original's
//! `SetDeleteQuarantinesIn7DaysIfNeeded`/`RemoveQuarantines`
//! (`src/kp_includes/functions/quarantines.au3`). The pure decisions
//! (what date, what command line, what file format) live in
//! `kprm_engine::quarantine_schedule`; this is the real file-copying,
//! `schtasks.exe`-calling, and report-appending glue around it.

use std::io::Write as _;

use kprm_engine::paths::KnownDirs;
use kprm_engine::ports::CommandRunner;
use kprm_engine::report::EventResult;

use crate::known_dirs::EnvKnownDirs;
use crate::timestamp::current_local_datetime_fields;

const DAYS_FROM_NOW: u32 = 7;

fn tasks_dir(dirs: &EnvKnownDirs) -> String {
    format!("{}\\KPRM\\tasks-quarantines", dirs.home_drive())
}

/// Copies the currently running executable into a stable folder so a
/// task scheduled now still has something to run in a week, even if the
/// user later moves or deletes wherever they originally ran this from —
/// mirrors the original's own `FileCopy(@AutoItExe, ...)`.
fn ensure_agent_copy(dirs: &EnvKnownDirs) -> Option<String> {
    let dir = tasks_dir(dirs);
    std::fs::create_dir_all(&dir).ok()?;
    let agent_path = format!("{dir}\\kprm-quarantine-agent.exe");
    if !std::path::Path::new(&agent_path).exists() {
        let current_exe = std::env::current_exe().ok()?;
        std::fs::copy(current_exe, &agent_path).ok()?;
    }
    Some(agent_path)
}

/// Schedules `items` (`(tool, target)` pairs already reported as
/// [`kprm_engine::report::EventResult::ScheduledIn7Days`]) for real
/// deletion 7 days from now: copies the current exe as a standby agent,
/// writes a list file (the current report's path, if any, plus the
/// items), and creates a one-time `schtasks.exe` task that runs the
/// agent with `--quarantine-cleanup <list file>`. Does nothing (and
/// returns `true`) if `items` is empty.
pub fn schedule_deferred_deletion(
    commands: &mut dyn CommandRunner,
    dirs: &EnvKnownDirs,
    report_path: Option<&str>,
    items: &[(String, String)],
) -> bool {
    if items.is_empty() {
        return true;
    }

    let Some(agent_path) = ensure_agent_copy(dirs) else {
        return false;
    };

    let timestamp = crate::timestamp::current_timestamp();
    let list_file = format!("{}\\quarantine-{timestamp}.txt", tasks_dir(dirs));
    let list_contents =
        kprm_engine::quarantine_schedule::format_list_file(report_path.unwrap_or(""), items);
    if std::fs::write(&list_file, list_contents).is_err() {
        return false;
    }

    let task_name = format!("KpRm-quarantine-{timestamp}");
    let today = current_local_datetime_fields();
    let args = kprm_engine::quarantine_schedule::schtasks_create_args(
        &task_name,
        &agent_path,
        &list_file,
        today,
        DAYS_FROM_NOW,
    );
    let arg_refs: Vec<&str> = args.iter().map(String::as_str).collect();

    commands.run("schtasks.exe", &arg_refs)
}

/// The headless entry point run by the copied agent when its scheduled
/// task fires (`<exe> --quarantine-cleanup <list_file>`, checked for in
/// each front-end's `main()` before doing anything else): parses
/// `list_file`, deletes everything for real, appends the outcome to the
/// original report if it still exists, then best-effort removes the
/// scheduled task and the list file. The agent exe copy itself is left
/// behind — a self-delete-while-running trick isn't worth it for a few
/// leftover kilobytes under `%HOMEDRIVE%\KPRM\tasks-quarantines`.
pub fn run_quarantine_cleanup(list_file: &str) {
    let Ok(content) = std::fs::read_to_string(list_file) else {
        return;
    };
    let (report_path, items) = kprm_engine::quarantine_schedule::parse_list_file(&content);

    let mut fs = crate::filesystem::WinFileSystem;
    let report = kprm_engine::quarantine_schedule::run_deferred_cleanup(&mut fs, &items);

    if !report_path.is_empty() {
        append_to_report(&report_path, &report);
    }

    cleanup_task_and_list_file(list_file);
}

fn append_to_report(report_path: &str, report: &kprm_engine::report::Report) {
    let mut text = String::from("\r\n- Deferred deletions (7 days) -\r\n");
    for event in &report.events {
        let symbol = match event.result {
            EventResult::Removed => "[OK]",
            EventResult::ScheduledOnReboot => "[R]",
            _ => "[?]",
        };
        text.push_str(&format!("  {symbol} {} ({})\r\n", event.target, event.tool));
    }
    if report.events.is_empty() {
        text.push_str("  [I] Nothing to remove (already gone)\r\n");
    }

    if let Ok(mut file) = std::fs::OpenOptions::new().append(true).open(report_path) {
        let _ = file.write_all(text.as_bytes());
    }
}

fn cleanup_task_and_list_file(list_file: &str) {
    if let Some(timestamp) = std::path::Path::new(list_file)
        .file_stem()
        .and_then(|s| s.to_str())
        .and_then(|stem| stem.strip_prefix("quarantine-"))
    {
        let task_name = format!("KpRm-quarantine-{timestamp}");
        let mut commands = crate::command::RealCommandRunner;
        let _ = commands.run("schtasks.exe", &["/delete", "/tn", &task_name, "/f"]);
    }
    let _ = std::fs::remove_file(list_file);
}
