//! The "Dans 7 jours" deferred quarantine deletion — the counterpart of
//! the original's `SetDeleteQuarantinesIn7DaysIfNeeded`/
//! `RemoveQuarantines` (`src/kp_includes/functions/quarantines.au3`),
//! which copies itself into a stable folder, records the pending
//! deletions as per-item `HKLM\Software\KPRM\quarantines` registry
//! values, and creates a Task Scheduler entry (COM API) that runs the
//! copy 7 days later. This uses `schtasks.exe` (already used elsewhere
//! via [`crate::ports::CommandRunner`], no COM bindings needed) and a
//! plain list file instead of the registry — everything here is pure and
//! unit-tested without Windows; `kprm-windows::quarantine_agent` does the
//! real copying/scheduling/file I/O around it.

use crate::ports::{FileSystem, Removal};
use crate::report::{EventResult, Report};

/// Adds `days` calendar days to a plain Gregorian `(year, month, day)`.
/// Pure calendar arithmetic, no timezone/instant semantics at all — which
/// is correct here: a maintenance task scheduled a week out doesn't need
/// to account for a DST transition landing in between.
pub fn add_days(year: u32, month: u32, day: u32, days: u32) -> (u32, u32, u32) {
    let mut year = year;
    let mut month = month;
    let mut day = day + days;
    loop {
        let len = days_in_month(year, month);
        if day <= len {
            break;
        }
        day -= len;
        month += 1;
        if month > 12 {
            month = 1;
            year += 1;
        }
    }
    (year, month, day)
}

fn is_leap_year(year: u32) -> bool {
    (year.is_multiple_of(4) && !year.is_multiple_of(100)) || year.is_multiple_of(400)
}

fn days_in_month(year: u32, month: u32) -> u32 {
    match month {
        1 | 3 | 5 | 7 | 8 | 10 | 12 => 31,
        4 | 6 | 9 | 11 => 30,
        2 if is_leap_year(year) => 29,
        2 => 28,
        _ => 30,
    }
}

/// Builds the `schtasks.exe /create` argument list for a one-time task
/// that runs `agent_exe --quarantine-cleanup <list_file>` `days_from_now`
/// days after `today` (`(year, month, day, hour, minute)`, local time).
pub fn schtasks_create_args(
    task_name: &str,
    agent_exe: &str,
    list_file: &str,
    today: (u32, u32, u32, u32, u32),
    days_from_now: u32,
) -> Vec<String> {
    let (year, month, day, hour, minute) = today;
    let (fy, fm, fd) = add_days(year, month, day, days_from_now);
    vec![
        "/create".to_string(),
        "/f".to_string(),
        "/tn".to_string(),
        task_name.to_string(),
        "/sc".to_string(),
        "once".to_string(),
        "/sd".to_string(),
        format!("{fm:02}/{fd:02}/{fy:04}"),
        "/st".to_string(),
        format!("{hour:02}:{minute:02}"),
        "/rl".to_string(),
        "highest".to_string(),
        "/tr".to_string(),
        format!("\"{agent_exe}\" --quarantine-cleanup \"{list_file}\""),
    ]
}

/// Serializes the report path (for the cleanup to later append its
/// outcome to, empty if there wasn't one) and the `(tool, target)` items
/// to delete, one per line as `tool|target`.
pub fn format_list_file(report_path: &str, items: &[(String, String)]) -> String {
    let mut out = String::new();
    out.push_str(report_path);
    out.push_str("\r\n");
    for (tool, target) in items {
        out.push_str(tool);
        out.push('|');
        out.push_str(target);
        out.push_str("\r\n");
    }
    out
}

/// The inverse of [`format_list_file`].
pub fn parse_list_file(content: &str) -> (String, Vec<(String, String)>) {
    let mut lines = content.lines();
    let report_path = lines.next().unwrap_or("").to_string();
    let items = lines
        .filter_map(|line| line.split_once('|'))
        .map(|(tool, target)| (tool.to_string(), target.to_string()))
        .collect();
    (report_path, items)
}

/// Deletes every `(tool, target)` pair for real — the headless
/// counterpart of the original's `RemoveQuarantines`, run when the
/// scheduled task fires 7 days after being created. An item already
/// gone by then is skipped without being reported, matching the
/// original's own silent `ContinueLoop` in that case.
pub fn run_deferred_cleanup(fs: &mut dyn FileSystem, items: &[(String, String)]) -> Report {
    let mut report = Report::default();

    for (tool, target) in items {
        let removal = match fs.kind(target) {
            Some(kprm_catalog::EntryKind::Folder) => fs.remove_dir(target),
            Some(kprm_catalog::EntryKind::File) => fs.remove_file(target),
            None => continue,
        };
        let result = match removal {
            Removal::Deleted => EventResult::Removed,
            Removal::ScheduledOnReboot => EventResult::ScheduledOnReboot,
            Removal::NotFound => continue,
        };
        report.push(tool.clone(), "quarantine_7days", target.clone(), result);
    }

    report
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::fakes::FakeFileSystem;

    #[test]
    fn add_days_stays_within_the_same_month() {
        assert_eq!(add_days(2026, 9, 4, 7), (2026, 9, 11));
    }

    #[test]
    fn add_days_rolls_over_into_the_next_month() {
        assert_eq!(add_days(2026, 9, 28, 7), (2026, 10, 5));
    }

    #[test]
    fn add_days_rolls_over_into_the_next_year() {
        assert_eq!(add_days(2026, 12, 28, 7), (2027, 1, 4));
    }

    #[test]
    fn add_days_accounts_for_leap_years() {
        // 2028 is a leap year: Feb has 29 days.
        assert_eq!(add_days(2028, 2, 25, 7), (2028, 3, 3));
        // 2027 is not: Feb has 28 days.
        assert_eq!(add_days(2027, 2, 25, 7), (2027, 3, 4));
    }

    #[test]
    fn schtasks_create_args_builds_the_expected_command_line() {
        let args = schtasks_create_args(
            "KpRm-quarantine-20260905113716",
            r"C:\KPRM\tasks-quarantines\kprm-quarantine-agent.exe",
            r"C:\KPRM\tasks-quarantines\quarantine-20260905113716.txt",
            (2026, 9, 4, 11, 37),
            7,
        );
        assert!(args.contains(&"/sd".to_string()));
        assert!(args.contains(&"09/11/2026".to_string()));
        assert!(args.contains(&"/st".to_string()));
        assert!(args.contains(&"11:37".to_string()));
        assert!(args
            .iter()
            .any(|a| a.contains("--quarantine-cleanup")
                && a.contains("quarantine-20260905113716.txt")));
    }

    #[test]
    fn list_file_round_trips() {
        let items = vec![
            ("AdwCleaner".to_string(), r"C:\_OTL\junk.dll".to_string()),
            ("OTL".to_string(), r"C:\_OTL".to_string()),
        ];
        let text = format_list_file(r"C:\KPRM\kprm-20260905113716.txt", &items);
        let (report_path, parsed) = parse_list_file(&text);
        assert_eq!(report_path, r"C:\KPRM\kprm-20260905113716.txt");
        assert_eq!(parsed, items);
    }

    #[test]
    fn run_deferred_cleanup_deletes_existing_items_and_skips_missing_ones() {
        let mut fs = FakeFileSystem::new();
        fs.add_file(r"C:\_OTL\junk.dll", None);

        let items = vec![
            ("AdwCleaner".to_string(), r"C:\_OTL\junk.dll".to_string()),
            ("OTL".to_string(), r"C:\_OTL\already-gone.dll".to_string()),
        ];

        let report = run_deferred_cleanup(&mut fs, &items);

        assert_eq!(report.events.len(), 1);
        assert_eq!(report.events[0].result, EventResult::Removed);
        assert_eq!(report.events[0].target, r"C:\_OTL\junk.dll");
    }

    #[test]
    fn run_deferred_cleanup_reports_a_locked_file_as_scheduled_on_reboot() {
        let mut fs = FakeFileSystem::new();
        fs.add_file(r"C:\_OTL\junk.dll", None);
        fs.lock(r"C:\_OTL\junk.dll");

        let items = vec![("AdwCleaner".to_string(), r"C:\_OTL\junk.dll".to_string())];
        let report = run_deferred_cleanup(&mut fs, &items);

        assert_eq!(report.events[0].result, EventResult::ScheduledOnReboot);
    }
}
