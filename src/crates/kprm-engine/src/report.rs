//! The result of one orchestrator run: a flat list of per-element events,
//! independent of how a front-end chooses to render them (plain text list
//! for the CLI, a checkable list for the GUI's "Analyse personnalisée" tab,
//! or JSON via [`Report::to_json`] for machine consumption).

use serde::Serialize;

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
#[serde(tag = "status", content = "reason", rename_all = "snake_case")]
pub enum EventResult {
    Removed,
    ScheduledOnReboot,
    /// A quarantined element kept for this run (no policy chosen, or the
    /// user chose to keep quarantines).
    Kept,
    /// A quarantined element kept now, deletion scheduled 7 days out.
    ScheduledIn7Days,
    /// Search-only mode: the element was found but nothing was touched.
    Found,
    /// An uninstaller or external command was launched.
    Ran,
    Failed(String),
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct Event {
    pub tool: String,
    pub action_type: &'static str,
    /// File path, registry key, or process name/path, depending on
    /// `action_type`.
    pub target: String,
    pub result: EventResult,
}

#[derive(Debug, Clone, Default, Serialize)]
pub struct Report {
    pub events: Vec<Event>,
}

impl Report {
    pub fn push(
        &mut self,
        tool: impl Into<String>,
        action_type: &'static str,
        target: impl Into<String>,
        result: EventResult,
    ) {
        self.events.push(Event {
            tool: tool.into(),
            action_type,
            target: target.into(),
            result,
        });
    }

    pub fn merge(&mut self, other: Report) {
        self.events.extend(other.events);
    }

    pub fn count(&self, result: &EventResult) -> usize {
        self.events.iter().filter(|e| &e.result == result).count()
    }

    /// `true` when at least one element could not be deleted immediately
    /// and was scheduled for deletion on next boot (`MOVEFILE_DELAY_UNTIL_REBOOT`)
    /// — the front-end must then offer to restart the machine, mirroring
    /// the original's `RestartIfNeeded` (`functions.au3`).
    pub fn needs_restart(&self) -> bool {
        self.events
            .iter()
            .any(|e| e.result == EventResult::ScheduledOnReboot)
    }

    /// Renders a human-readable report, grouped by tool, in the spirit of
    /// the original's text log (`src/kp_includes/functions/utils.au3`'s
    /// `LogMessage`, `[OK]`/`[X]`/`[R]` prefixes) — not a byte-identical
    /// format, but the same idea: a plain-text file a technician can read
    /// and hand to a client. Structured as a banner, a numeric summary,
    /// one section per tool with aligned status symbols, and a dedicated
    /// error section, so it stays legible in a plain Notepad window.
    pub fn to_text(&self, title_lines: &[String]) -> String {
        const RULE: &str = "======================================================";
        const THIN_RULE: &str = "------------------------------------------------------";

        let mut out = String::new();
        out.push_str(RULE);
        out.push_str("\r\n");
        for line in title_lines {
            out.push_str(line);
            out.push_str("\r\n");
        }
        out.push_str(RULE);
        out.push_str("\r\n");

        if self.events.is_empty() {
            out.push_str("\r\nNo items found.\r\n");
            return out;
        }

        out.push_str("\r\nSummary\r\n");
        out.push_str(THIN_RULE);
        out.push_str("\r\n");
        for (label, count) in self.summary_counts() {
            out.push_str(&format!("  {label:<32} : {count}\r\n"));
        }

        let mut tools: Vec<&str> = self.events.iter().map(|e| e.tool.as_str()).collect();
        tools.sort_unstable();
        tools.dedup();

        for tool in tools {
            out.push_str(&format!("\r\n{tool}\r\n{THIN_RULE}\r\n"));
            for event in self.events.iter().filter(|e| e.tool == tool) {
                let symbol = symbol_for(&event.result);
                out.push_str(&format!(
                    "  {symbol:<7} {:<50} ({})\r\n",
                    event.target, event.action_type
                ));
            }
        }

        let failures: Vec<&Event> = self
            .events
            .iter()
            .filter(|e| matches!(e.result, EventResult::Failed(_)))
            .collect();
        if !failures.is_empty() {
            out.push_str(&format!("\r\n{RULE}\r\nErrors\r\n{RULE}\r\n"));
            for event in failures {
                if let EventResult::Failed(message) = &event.result {
                    out.push_str(&format!(
                        "  [X] {} ({}) : {message}\r\n",
                        event.target, event.action_type
                    ));
                }
            }
        }

        out.push_str(&format!("\r\n{RULE}\r\nEnd of report.\r\n"));

        out
    }

    /// Counts events per category, in display order, for the summary
    /// block at the top of [`Report::to_text`].
    fn summary_counts(&self) -> [(&'static str, usize); 7] {
        let mut removed = 0;
        let mut ran = 0;
        let mut scheduled_on_reboot = 0;
        let mut kept = 0;
        let mut scheduled_in_7_days = 0;
        let mut found = 0;
        let mut failed = 0;
        for event in &self.events {
            match event.result {
                EventResult::Removed => removed += 1,
                EventResult::Ran => ran += 1,
                EventResult::ScheduledOnReboot => scheduled_on_reboot += 1,
                EventResult::Kept => kept += 1,
                EventResult::ScheduledIn7Days => scheduled_in_7_days += 1,
                EventResult::Found => found += 1,
                EventResult::Failed(_) => failed += 1,
            }
        }
        [
            ("Removed", removed),
            ("Programs launched", ran),
            ("Scheduled for removal on reboot", scheduled_on_reboot),
            ("Kept (quarantine)", kept),
            ("Removal scheduled (7 days)", scheduled_in_7_days),
            ("Found (scan only)", found),
            ("Failed", failed),
        ]
    }

    /// Serializes the raw event list as pretty-printed JSON, for scripts
    /// or other tools to consume instead of parsing the plain-text report
    /// — spec §7's "JSON optionnel". `title_lines` (machine info, version,
    /// timestamp) isn't included here since it's meant for a human reading
    /// a text file, not structured data.
    pub fn to_json(&self) -> String {
        serde_json::to_string_pretty(self).expect("Report only contains plain strings and enums")
    }
}

fn symbol_for(result: &EventResult) -> &'static str {
    match result {
        EventResult::Removed | EventResult::Ran => "[OK]",
        EventResult::ScheduledOnReboot => "[R]",
        EventResult::Kept => "[KEEP]",
        EventResult::ScheduledIn7Days => "[7J]",
        EventResult::Found => "[?]",
        EventResult::Failed(_) => "[X]",
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn to_json_round_trips_through_serde_json_value() {
        let mut report = Report::default();
        report.push(
            "AdwCleaner",
            "desktop",
            r"C:\Desktop\AdwCleaner.exe",
            EventResult::Removed,
        );
        report.push(
            "AdwCleaner",
            "process",
            "AdwCleaner.exe",
            EventResult::Failed("boom".to_string()),
        );

        let json = report.to_json();
        let value: serde_json::Value = serde_json::from_str(&json).unwrap();
        let events = value["events"].as_array().unwrap();

        assert_eq!(events.len(), 2);
        assert_eq!(events[0]["tool"], "AdwCleaner");
        assert_eq!(events[0]["result"]["status"], "removed");
        assert_eq!(events[1]["result"]["status"], "failed");
        assert_eq!(events[1]["result"]["reason"], "boom");
    }

    #[test]
    fn needs_restart_only_when_something_is_scheduled_on_reboot() {
        let mut report = Report::default();
        report.push("A", "file", "a", EventResult::Removed);
        assert!(!report.needs_restart());

        report.push("A", "file", "b", EventResult::ScheduledOnReboot);
        assert!(report.needs_restart());
    }

    #[test]
    fn empty_report_says_so() {
        let report = Report::default();
        let text = report.to_text(&["KpRm report".to_string()]);
        assert!(text.contains("KpRm report"));
        assert!(text.contains("No items found"));
    }

    #[test]
    fn groups_events_by_tool_and_lists_failures_separately() {
        let mut report = Report::default();
        report.push(
            "AdwCleaner",
            "desktop",
            r"C:\Desktop\AdwCleaner.exe",
            EventResult::Removed,
        );
        report.push(
            "AdwCleaner",
            "process",
            "AdwCleaner.exe",
            EventResult::Failed("boom".to_string()),
        );
        report.push("OTL", "folder", r"C:\_OTL", EventResult::ScheduledOnReboot);

        let text = report.to_text(&[]);

        assert!(text.contains("Summary"));
        assert!(text.contains("Removed"));
        assert!(text.contains("AdwCleaner\r\n"));
        assert!(text.contains("OTL\r\n"));
        assert!(text.contains("[OK]") && text.contains("C:\\Desktop\\AdwCleaner.exe"));
        assert!(text.contains("[R]") && text.contains("C:\\_OTL") && text.contains("(folder)"));
        assert!(text.contains("Errors"));
        assert!(text.contains("[X] AdwCleaner.exe (process) : boom"));
        assert!(text.contains("End of report."));
    }

    #[test]
    fn summary_counts_every_result_category() {
        let mut report = Report::default();
        report.push("A", "file", "a", EventResult::Removed);
        report.push("A", "process", "b", EventResult::Ran);
        report.push("A", "file", "c", EventResult::ScheduledOnReboot);
        report.push("A", "quarantine", "d", EventResult::Kept);
        report.push("A", "quarantine", "e", EventResult::ScheduledIn7Days);
        report.push("A", "file", "f", EventResult::Found);
        report.push("A", "file", "g", EventResult::Failed("oops".to_string()));

        let text = report.to_text(&[]);
        let normalized: Vec<String> = text
            .lines()
            .map(|line| line.split_whitespace().collect::<Vec<_>>().join(" "))
            .collect();

        for expected in [
            "Removed : 1",
            "Programs launched : 1",
            "Scheduled for removal on reboot : 1",
            "Kept (quarantine) : 1",
            "Removal scheduled (7 days) : 1",
            "Found (scan only) : 1",
            "Failed : 1",
        ] {
            assert!(
                normalized.iter().any(|line| line == expected),
                "expected a summary line {expected:?}, got: {normalized:#?}"
            );
        }
    }
}
