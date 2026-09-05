//! KpRm's GUI front-end. Same `kprm_engine::orchestrator`/`kprm_windows`
//! plumbing as `kprm-cli`, wired to an egui/eframe window instead of a
//! terminal. Borderless window with a hand-drawn title bar, matching the
//! shared design mockup (docs/design/*.dc.html) more closely than a stock
//! OS-decorated window would.

mod app;
mod theme;
mod worker;

use eframe::egui;

fn main() -> eframe::Result<()> {
    // Headless mode: the copied "quarantine agent" exe
    // (kprm_windows::quarantine_agent) launches itself this way when a
    // "Dans 7 jours" schtasks.exe entry fires, 7 days after being
    // scheduled — do the real deletions and exit, never creating a
    // window (see rust/README.md).
    if let Some(list_file) = quarantine_cleanup_arg() {
        kprm_windows::run_quarantine_cleanup(&list_file);
        return Ok(());
    }

    // The PE resource icon (build.rs + assets/icon.rc) is what Explorer and
    // the taskbar show before the window even exists; this sets the same
    // icon for the window/title-bar/Alt+Tab once it's running, since a
    // borderless viewport doesn't pick one up from OS decorations.
    let icon = eframe::icon_data::from_png_bytes(include_bytes!("../assets/icon.png"))
        .expect("embedded icon.png must decode");

    let options = eframe::NativeOptions {
        viewport: egui::ViewportBuilder::default()
            .with_inner_size([820.0, 680.0])
            .with_min_inner_size([720.0, 480.0])
            .with_decorations(false)
            .with_transparent(false)
            .with_icon(icon),
        ..Default::default()
    };

    eframe::run_native(
        "KpRm",
        options,
        Box::new(|cc| {
            theme::install_fonts(&cc.egui_ctx);
            theme::install_visuals(&cc.egui_ctx);
            Ok(Box::<app::KprmApp>::default())
        }),
    )
}

fn quarantine_cleanup_arg() -> Option<String> {
    let args: Vec<String> = std::env::args().collect();
    let pos = args.iter().position(|a| a == "--quarantine-cleanup")?;
    args.get(pos + 1).cloned()
}
