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
}
