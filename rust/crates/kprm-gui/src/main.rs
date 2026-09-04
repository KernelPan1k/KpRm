//! KpRm's GUI front-end. Same `kprm_engine::orchestrator`/`kprm_windows`
//! plumbing as `kprm-cli`, wired to an egui/eframe window instead of a
//! terminal.

mod app;
mod worker;

use eframe::egui;

fn main() -> eframe::Result<()> {
    let options = eframe::NativeOptions {
        viewport: egui::ViewportBuilder::default()
            .with_inner_size([640.0, 620.0])
            .with_min_inner_size([480.0, 420.0]),
        ..Default::default()
    };

    eframe::run_native(
        "KpRm",
        options,
        Box::new(|cc| {
            cc.egui_ctx.set_visuals(egui::Visuals::dark());
            Ok(Box::<app::KprmApp>::default())
        }),
    )
}
