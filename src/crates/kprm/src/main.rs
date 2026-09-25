//! KpRm's single entry point, three ways in:
//! - No subcommand (a double-click, or a bare `kprm.exe`): launches the
//!   GUI, same as the original always did.
//! - A subcommand (`kprm.exe scan`, `kprm.exe remove --confirm`, ...):
//!   runs headless — see [`cli`].
//! - `kprm.exe --quarantine-cleanup <file>`: the hidden headless target
//!   the "Dans 7 jours" scheduled task reruns a week after being set up
//!   (`kprm_windows::quarantine_agent`) — checked first, before either
//!   clap or the GUI window get involved, since it isn't a documented
//!   subcommand.
//!
//! Kept as one binary (rather than a separate CLI/GUI pair) so the
//! "quarantine agent" copy always has *something* to rerun regardless of
//! which mode originally scheduled it, and so there's only one exe to
//! ship. Always requests UAC elevation on launch via `assets/app.manifest`
//! (see `build.rs`) — matching the original's own unconditional
//! `#RequireAdmin`, including for read-only CLI subcommands; see
//! `../../README.md` for the trade-off that was chosen deliberately.
//!
//! `windows_subsystem = "windows"` below means launching `kprm.exe` never
//! shows a console window of its own — the historical reason it was
//! *console* (so a launch failure printed a message instead of a silent
//! vanishing flash) no longer applies now that the GUI is native Win32/
//! GDI+ rather than `eframe`/OpenGL (see `../../BUILDING.md`). The CLI
//! subcommands are unaffected: run from an existing terminal, their
//! `println!`/`eprintln!` output still goes to that terminal, since a
//! GUI-subsystem process launched from one inherits its console handles
//! exactly like a console-subsystem one would — the attribute only
//! controls whether Windows auto-allocates a *new* console when the
//! process is started without one (a double-click, a shortcut, Explorer).
#![windows_subsystem = "windows"]

mod app;
mod app_icons;
mod cli;
mod theme;
mod worker;

use clap::Parser;

fn main() -> std::process::ExitCode {
    if let Some(list_file) = quarantine_cleanup_arg() {
        kprm_windows::run_quarantine_cleanup(&list_file);
        return std::process::ExitCode::SUCCESS;
    }

    // Detected once, early, so both the "already running" message box and
    // the GUI itself use the same locale — the real counterpart of the
    // original's @OSLang-based Lang_XX() selection (kp_languages.au3).
    let translations =
        kprm_i18n::Translations::for_system_locale(&kprm_windows::user_locale_name());

    // Single-instance guard (original: kprm_is_running.au3's named mutex),
    // for the interactive paths only — deliberately not applied above to
    // --quarantine-cleanup, unlike the original: that would block the
    // unattended 7-day scheduled task from ever running its one job just
    // because the interactive GUI happens to be open at the same time.
    if kprm_windows::another_instance_is_running() {
        let message = translations
            .get("already-running")
            .unwrap_or_else(|_| "KpRm is already running!".to_string());
        kprm_windows::show_message_box("KpRm", &message);
        return std::process::ExitCode::FAILURE;
    }

    let cli = cli::Cli::parse();
    if let Some(command) = cli.command {
        return cli::run(command);
    }

    match run_gui(translations) {
        Ok(()) => std::process::ExitCode::SUCCESS,
        Err(err) => {
            eprintln!("GUI error: {err}");
            std::process::ExitCode::FAILURE
        }
    }
}

fn quarantine_cleanup_arg() -> Option<String> {
    let args: Vec<String> = std::env::args().collect();
    let pos = args.iter().position(|a| a == "--quarantine-cleanup")?;
    args.get(pos + 1).cloned()
}

fn run_gui(translations: kprm_i18n::Translations) -> windows::core::Result<()> {
    // The window/title-bar/Alt+Tab icon: the PE resource icon (build.rs +
    // assets/icon.rc) is what Explorer and the taskbar show before the
    // window even exists — TODO (later phase): set the same one on the
    // HWND itself via WM_SETICON, matching the previous eframe behavior.
    kprm_win32gui::window::run(
        kprm_win32gui::window::WindowConfig {
            title: "KpRm".to_string(),
            size: (820, 680),
            min_size: (720, 480),
        },
        move |hwnd| app::KprmApp::new(translations, hwnd),
    )
}
