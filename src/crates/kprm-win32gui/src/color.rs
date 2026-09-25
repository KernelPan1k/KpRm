//! Straight (non-premultiplied) RGBA color, replacing `egui::Color32` in
//! the ported `theme.rs` — kept as a plain 4-byte struct with a real alpha
//! channel so `kprm`'s semi-transparent border colors (which `egui::Color32`
//! flattened to opaque today) become genuinely translucent when drawn via
//! GDI+.

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Color {
    pub r: u8,
    pub g: u8,
    pub b: u8,
    pub a: u8,
}

impl Color {
    pub const fn rgb(r: u8, g: u8, b: u8) -> Self {
        Self { r, g, b, a: 255 }
    }

    pub const fn rgba(r: u8, g: u8, b: u8, a: u8) -> Self {
        Self { r, g, b, a }
    }

    /// GDI+'s `ARGB` (`0xAARRGGBB`) packing, used by every `Gdip*` call.
    pub const fn to_argb(self) -> u32 {
        ((self.a as u32) << 24) | ((self.r as u32) << 16) | ((self.g as u32) << 8) | (self.b as u32)
    }

    pub const fn with_alpha(self, a: u8) -> Self {
        Self { a, ..self }
    }
}
