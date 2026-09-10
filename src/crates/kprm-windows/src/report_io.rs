//! Writing a [`kprm_engine::report::Report`] to disk and opening it in
//! Notepad — the real counterpart of the original's `LogMessage`/
//! `OpenReport` (`src/kp_includes/functions/utils.au3`). See
//! docs/RUST-REWRITE-SPEC.md §2.15. Shared by `kprm-cli` and `kprm-gui` so
//! both front-ends behave the same way after a real run.

use kprm_engine::paths::KnownDirs;
use kprm_engine::report::Report;

use crate::known_dirs::EnvKnownDirs;

/// Writes `report` to `%HOMEDRIVE%\KPRM\kprm-<timestamp>.txt` and a copy on
/// the Desktop, then opens the first one that was written in Notepad. Also
/// writes a `.json` copy next to the `.txt` one (spec §7's "JSON
/// optionnel") for scripts to consume instead of parsing the plain-text
/// report — Notepad only ever opens the `.txt`. Intended for a real run
/// (`RunAutomatic`/`remove`/"Supprimer la sélection") — a search-only scan
/// should not call this, matching the original's `KpSearch` never opening
/// a report either. Returns the `.txt` path actually opened (the Desktop
/// one falls back for the caller if the `%HOMEDRIVE%\KPRM` write failed),
/// so a "Dans 7 jours" quarantine schedule can append its own outcome to
/// the same file once it runs (see [`crate::quarantine_agent`]) — `None`
/// if both writes failed.
pub fn write_and_open_report(
    report: &Report,
    dirs: &EnvKnownDirs,
    title_lines: &[String],
) -> Option<String> {
    let text = report.to_text(title_lines);
    let json = report.to_json();

    let kprm_dir = format!("{}\\KPRM", dirs.home_drive());
    if std::fs::create_dir_all(&kprm_dir).is_err() {
        return None;
    }

    let timestamp = crate::timestamp::current_timestamp();
    let filename = format!("kprm-{timestamp}.txt");
    let home_report = format!("{kprm_dir}\\{filename}");
    let desktop_report = format!("{}\\{filename}", dirs.desktop());
    let json_report = format!("{kprm_dir}\\kprm-{timestamp}.json");

    let wrote_home = std::fs::write(&home_report, &text).is_ok();
    let wrote_desktop = std::fs::write(&desktop_report, &text).is_ok();
    let _ = std::fs::write(&json_report, &json);

    let report_to_open = if wrote_home {
        Some(home_report)
    } else if wrote_desktop {
        Some(desktop_report)
    } else {
        None
    };

    if let Some(path) = &report_to_open {
        let _ = std::process::Command::new("notepad.exe").arg(path).spawn();
    }

    report_to_open
}
