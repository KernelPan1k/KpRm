//! Quarantine handling decision table, ported from the shared logic in
//! `RemoveFolder` and `CleanDirectoryContent`
//! (`src/kp_includes/functions/{remove,functions}.au3`). See
//! docs/RUST-REWRITE-SPEC.md §2.7.

/// The user's chosen quarantine policy for this run (the three-way choice
/// exposed in the UI mockup: Conserver / Maintenant / Dans 7 jours — an
/// explicit third state where the original only had two checkboxes and left
/// "neither checked" as an implicit "keep forever").
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum QuarantineMode {
    Keep,
    Now,
    In7Days,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum QuarantineDecision {
    DeleteNow,
    Keep,
    ScheduleIn7Days,
}

/// Decides what happens to one element given whether the catalog marked it
/// `quarantine = true` and the user's chosen policy for this run.
///
/// An element *not* flagged as quarantine in the catalog is always deleted
/// immediately, regardless of the chosen policy — the policy only ever
/// restrains deletion, it never blocks a non-sensitive removal.
pub fn decide(is_quarantined: bool, mode: QuarantineMode) -> QuarantineDecision {
    if !is_quarantined {
        return QuarantineDecision::DeleteNow;
    }
    match mode {
        QuarantineMode::Now => QuarantineDecision::DeleteNow,
        QuarantineMode::In7Days => QuarantineDecision::ScheduleIn7Days,
        QuarantineMode::Keep => QuarantineDecision::Keep,
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn non_quarantined_elements_are_always_deleted_now() {
        for mode in [
            QuarantineMode::Keep,
            QuarantineMode::Now,
            QuarantineMode::In7Days,
        ] {
            assert_eq!(decide(false, mode), QuarantineDecision::DeleteNow);
        }
    }

    #[test]
    fn quarantined_element_kept_by_default() {
        assert_eq!(decide(true, QuarantineMode::Keep), QuarantineDecision::Keep);
    }

    #[test]
    fn quarantined_element_deleted_now_when_requested() {
        assert_eq!(
            decide(true, QuarantineMode::Now),
            QuarantineDecision::DeleteNow
        );
    }

    #[test]
    fn quarantined_element_scheduled_in_7_days_when_requested() {
        assert_eq!(
            decide(true, QuarantineMode::In7Days),
            QuarantineDecision::ScheduleIn7Days
        );
    }
}
