//! Embeds `assets/icon.ico` as the .exe's PE resource icon (the icon shown
//! by Explorer, the taskbar, and Alt+Tab before the window even exists —
//! without this, Windows falls back to a generic default). Runtime also
//! sets the same icon via `eframe`'s `ViewportBuilder::with_icon` (see
//! `src/main.rs`) for the title-bar/Alt+Tab icon while the window is open.
fn main() {
    if std::env::var("CARGO_CFG_TARGET_OS").as_deref() == Ok("windows") {
        match embed_resource::compile("assets/icon.rc", embed_resource::NONE) {
            embed_resource::CompilationResult::Ok => {}
            other => panic!(
                "failed to embed assets/icon.ico as the .exe resource icon: {other:?} \
                 (windres from a MinGW toolchain must be on PATH)"
            ),
        }
    }
}
