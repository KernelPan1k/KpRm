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
    let options = eframe::NativeOptions {
        viewport: egui::ViewportBuilder::default()
            .with_inner_size([820.0, 680.0])
            .with_min_inner_size([720.0, 480.0])
            .with_decorations(false)
            .with_transparent(false),
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
