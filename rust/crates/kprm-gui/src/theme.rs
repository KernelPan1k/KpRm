//! Color palette and fonts, approximating the oklch design tokens from the
//! shared HTML mockup (docs/design/*.dc.html) in sRGB for egui. Not a
//! pixel-perfect port of the mockup (egui is immediate-mode, not CSS), but
//! the same dark theme + green/red/blue/amber semantic accents.

use eframe::egui::{self, Color32, FontData, FontDefinitions, FontFamily};

pub const BG: Color32 = Color32::from_rgb(0x14, 0x16, 0x1b);
pub const BG_ELEVATED: Color32 = Color32::from_rgb(0x1b, 0x1e, 0x24);
pub const BG_PANEL: Color32 = Color32::from_rgb(0x18, 0x1b, 0x21);
pub const BG_HOVER: Color32 = Color32::from_rgb(0x26, 0x2a, 0x32);
#[allow(dead_code)] // reserved for stronger dividers, not yet used
pub const BORDER: Color32 = Color32::from_rgb(0x35, 0x39, 0x42);
pub const BORDER_SOFT: Color32 = Color32::from_rgb(0x24, 0x27, 0x2e);

pub const TEXT_1: Color32 = Color32::from_rgb(0xee, 0xf0, 0xf2);
pub const TEXT_2: Color32 = Color32::from_rgb(0x9a, 0x9f, 0xa8);
pub const TEXT_3: Color32 = Color32::from_rgb(0x6b, 0x6f, 0x77);

pub const GREEN: Color32 = Color32::from_rgb(0x55, 0xc9, 0x8a);
pub const GREEN_BG: Color32 = Color32::from_rgba_premultiplied(0x14, 0x2a, 0x20, 255);
pub const RED: Color32 = Color32::from_rgb(0xe0, 0x52, 0x4a);
pub const RED_BG: Color32 = Color32::from_rgba_premultiplied(0x2e, 0x16, 0x15, 255);
pub const BLUE: Color32 = Color32::from_rgb(0x5b, 0x9e, 0xf5);
pub const BLUE_BG: Color32 = Color32::from_rgba_premultiplied(0x14, 0x22, 0x33, 255);
pub const AMBER: Color32 = Color32::from_rgb(0xe0, 0xb6, 0x4a);

pub const RADIUS: f32 = 8.0;

/// Loads the embedded Space Grotesk (headings/body) and IBM Plex Mono
/// (paths, version pill, status text) faces, replacing egui's defaults.
pub fn install_fonts(ctx: &egui::Context) {
    let mut fonts = FontDefinitions::default();

    fonts.font_data.insert(
        "space_grotesk".to_owned(),
        FontData::from_static(include_bytes!("../assets/fonts/SpaceGrotesk.ttf")),
    );
    fonts.font_data.insert(
        "ibm_plex_mono".to_owned(),
        FontData::from_static(include_bytes!("../assets/fonts/IBMPlexMono-Regular.ttf")),
    );

    fonts
        .families
        .entry(FontFamily::Proportional)
        .or_default()
        .insert(0, "space_grotesk".to_owned());
    fonts
        .families
        .entry(FontFamily::Monospace)
        .or_default()
        .insert(0, "ibm_plex_mono".to_owned());

    ctx.set_fonts(fonts);
}

/// Dark visuals tuned to the palette above (backgrounds, selection color,
/// widget rounding) instead of egui's stock dark theme.
pub fn install_visuals(ctx: &egui::Context) {
    let mut visuals = egui::Visuals::dark();
    visuals.override_text_color = Some(TEXT_1);
    visuals.window_fill = BG;
    visuals.panel_fill = BG;
    visuals.widgets.noninteractive.bg_fill = BG_PANEL;
    visuals.widgets.inactive.bg_fill = BG_PANEL;
    visuals.widgets.hovered.bg_fill = BG_HOVER;
    visuals.widgets.active.bg_fill = BG_HOVER;
    visuals.selection.bg_fill = BLUE.linear_multiply(0.35);
    visuals.selection.stroke = egui::Stroke::new(1.0_f32, BLUE);
    visuals.widgets.noninteractive.bg_stroke = egui::Stroke::new(1.0_f32, BORDER_SOFT);
    ctx.set_visuals(visuals);
}
