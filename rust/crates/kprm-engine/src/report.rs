//! The result of one orchestrator run: a flat list of per-element events,
//! independent of how a front-end chooses to render them (plain text list
//! for the CLI, a checkable list for the GUI's "Analyse personnalisée" tab).

#[derive(Debug, Clone, PartialEq, Eq)]
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

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Event {
    pub tool: String,
    pub action_type: &'static str,
    /// File path, registry key, or process name/path, depending on
    /// `action_type`.
    pub target: String,
    pub result: EventResult,
}

#[derive(Debug, Clone, Default)]
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

    /// Renders a human-readable report, grouped by tool, in the spirit of
    /// the original's text log (`src/kp_includes/functions/utils.au3`'s
    /// `LogMessage`, `[OK]`/`[X]`/`[R]` prefixes) — not a byte-identical
    /// format, but the same idea: a plain-text file a technician can read
    /// and hand to a client.
    pub fn to_text(&self, title_lines: &[String]) -> String {
        let mut out = String::new();
        for line in title_lines {
            out.push_str(line);
            out.push_str("\r\n");
        }

        if self.events.is_empty() {
            out.push_str("\r\nAucun élément trouvé.\r\n");
            return out;
        }

        let mut tools: Vec<&str> = self.events.iter().map(|e| e.tool.as_str()).collect();
        tools.sort_unstable();
        tools.dedup();

        for tool in tools {
            out.push_str(&format!("\r\n  ## {tool}\r\n"));
            for event in self.events.iter().filter(|e| e.tool == tool) {
                let symbol = symbol_for(&event.result);
                out.push_str(&format!(
                    "    {symbol} {} ({})\r\n",
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
            out.push_str("\r\n- Erreurs -\r\n");
            for event in failures {
                if let EventResult::Failed(message) = &event.result {
                    out.push_str(&format!(
                        "    [X] {} ({}) : {message}\r\n",
                        event.target, event.action_type
                    ));
                }
            }
        }

        out
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
    fn empty_report_says_so() {
        let report = Report::default();
        let text = report.to_text(&["KpRm report".to_string()]);
        assert!(text.contains("KpRm report"));
        assert!(text.contains("Aucun élément trouvé"));
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

        assert!(text.contains("## AdwCleaner"));
        assert!(text.contains("## OTL"));
        assert!(text.contains("[OK] C:\\Desktop\\AdwCleaner.exe (desktop)"));
        assert!(text.contains("[R] C:\\_OTL (folder)"));
        assert!(text.contains("- Erreurs -"));
        assert!(text.contains("[X] AdwCleaner.exe (process) : boom"));
    }
}
