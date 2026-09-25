//! Color palette and fonts — ported from the original `egui` theme to
//! `kprm-win32gui`'s plain `Color` type. `BORDER`/`BORDER_SOFT` are now
//! genuinely semi-transparent (GDI+ draws with real alpha), unlike the
//! flat opaque approximations the `egui` version had to use; the base RGB
//! values here are the previous flat colors with `BG` un-blended back out
//! at their original mockup alpha (0.65 / 0.35 — see
//! `docs/design/*.dc.html`'s `--border`/`--border-soft` tokens).

use kprm_win32gui::color::Color;
use kprm_win32gui::gdiplus::{Font, FontFamily, GdiplusError, PrivateFontCollection};
use windows::Win32::Graphics::GdiPlus::FontStyleRegular;

pub const BG: Color = Color::rgb(0x14, 0x16, 0x1b);
pub const BG_ELEVATED: Color = Color::rgb(0x1b, 0x1e, 0x24);
pub const BG_PANEL: Color = Color::rgb(0x18, 0x1b, 0x21);
pub const BG_HOVER: Color = Color::rgb(0x26, 0x2a, 0x32);
pub const BORDER: Color = Color::rgba(71, 76, 87, 166);
pub const BORDER_SOFT: Color = Color::rgba(66, 71, 81, 89);

pub const TEXT_1: Color = Color::rgb(0xee, 0xf0, 0xf2);
pub const TEXT_2: Color = Color::rgb(0x9a, 0x9f, 0xa8);
pub const TEXT_3: Color = Color::rgb(0x6b, 0x6f, 0x77);

pub const GREEN: Color = Color::rgb(0x55, 0xc9, 0x8a);
pub const GREEN_BG: Color = Color::rgb(0x14, 0x2a, 0x20);
pub const RED: Color = Color::rgb(0xe0, 0x52, 0x4a);
pub const RED_BG: Color = Color::rgb(0x2e, 0x16, 0x15);
pub const BLUE: Color = Color::rgb(0x5b, 0x9e, 0xf5);
pub const BLUE_BG: Color = Color::rgb(0x14, 0x22, 0x33);
pub const AMBER: Color = Color::rgb(0xe0, 0xb6, 0x4a);

pub const RADIUS: f32 = 8.0;

/// The embedded Space Grotesk (headings/body) and IBM Plex Mono (paths,
/// version pill, status text) faces, loaded as GDI+ private fonts — never
/// touches the system font registry. Only the Regular weight is embedded;
/// bold text uses GDI+'s own synthetic emboldening
/// (`FontStyle`'s `Bold` flag), matching the previous `egui` build's own
/// faux-bold rather than shipping separate bold TTFs.
pub struct Fonts {
    _collection: PrivateFontCollection,
    proportional: FontFamily,
    monospace: FontFamily,
}

impl Fonts {
    pub fn load() -> Result<Self, GdiplusError> {
        let collection = PrivateFontCollection::new()?;
        collection.add_memory_font(include_bytes!("../assets/fonts/SpaceGrotesk.ttf"))?;
        collection.add_memory_font(include_bytes!("../assets/fonts/IBMPlexMono-Regular.ttf"))?;
        let proportional = FontFamily::from_name("Space Grotesk", &collection)?;
        let monospace = FontFamily::from_name("IBM Plex Mono", &collection)?;
        Ok(Self { _collection: collection, proportional, monospace })
    }

    pub fn proportional(&self, size_px: f32) -> Font {
        Font::new(&self.proportional, size_px, FontStyleRegular)
            .expect("embedded proportional font must build at any reasonable size")
    }

    pub fn monospace(&self, size_px: f32) -> Font {
        Font::new(&self.monospace, size_px, FontStyleRegular)
            .expect("embedded monospace font must build at any reasonable size")
    }
}
