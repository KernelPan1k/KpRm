//! Writing a [`kprm_engine::report::Report`] to disk and opening it in
//! Notepad — the real counterpart of the original's `LogMessage`/
//! `OpenReport` (`src/kp_includes/functions/utils.au3`). See
//! docs/RUST-REWRITE-SPEC.md §2.15. Shared by `kprm-cli` and `kprm-gui` so
//! both front-ends behave the same way after a real run.

use kprm_engine::paths::KnownDirs;
use kprm_engine::report::Report;

use crate::known_dirs::EnvKnownDirs;

/// Writes `report` to `%HOMEDRIVE%\KPRM\kprm-<timestamp>.txt` and a copy on
/// the Desktop, then opens the first one that was written in Notepad.
/// Intended for a real run (`RunAutomatic`/`remove`/"Supprimer la
/// sélection") — a search-only scan should not call this, matching the
/// original's `KpSearch` never opening a report either.
pub fn write_and_open_report(report: &Report, dirs: &EnvKnownDirs, title_lines: &[String]) {
    let text = report.to_text(title_lines);

    let kprm_dir = format!("{}\\KPRM", dirs.home_drive());
    if std::fs::create_dir_all(&kprm_dir).is_err() {
        return;
    }

    let filename = format!("kprm-{}.txt", crate::timestamp::current_timestamp());
    let home_report = format!("{kprm_dir}\\{filename}");
    let desktop_report = format!("{}\\{filename}", dirs.desktop());

    let wrote_home = std::fs::write(&home_report, &text).is_ok();
    let _ = std::fs::write(&desktop_report, &text);

    let report_to_open = if wrote_home {
        &home_report
    } else {
        &desktop_report
    };
    let _ = std::process::Command::new("notepad.exe")
        .arg(report_to_open)
        .spawn();
}
