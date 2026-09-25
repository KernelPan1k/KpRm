//! Visual/interactive smoke test for `scroll.rs` — 30 fake rows in a small
//! viewport, scrollable with the mouse wheel. Not shipped; run with
//! `cargo run -p kprm-win32gui --example scroll_test`.

use kprm_win32gui::color::Color;
use kprm_win32gui::gdiplus::{Font, FontFamily, Graphics, Pen, PrivateFontCollection, SolidBrush, StringFormat};
use kprm_win32gui::scroll::ScrollState;
use kprm_win32gui::window::{self, AppWindow, HitZone};
use windows::Win32::Graphics::GdiPlus::{FontStyleRegular, RectF, StringAlignmentNear};

const ROW_HEIGHT: f32 = 28.0;
const ROW_COUNT: usize = 30;

struct DemoApp {
    _fonts: PrivateFontCollection,
    _family: FontFamily,
    font: Font,
    scroll: ScrollState,
}

impl DemoApp {
    fn new() -> Self {
        let fonts = PrivateFontCollection::new().unwrap();
        fonts.add_memory_font(include_bytes!("../../kprm/assets/fonts/SpaceGrotesk.ttf")).unwrap();
        let family = FontFamily::from_name("Space Grotesk", &fonts).unwrap();
        let font = Font::new(&family, 13.0, FontStyleRegular).unwrap();
        Self { _fonts: fonts, _family: family, font, scroll: ScrollState::default() }
    }
}

impl AppWindow for DemoApp {
    fn paint(&mut self, g: &Graphics, width: f32, height: f32) {
        let bg = SolidBrush::new(0xFF14161B).unwrap();
        g.fill_rect(RectF { X: 0.0, Y: 0.0, Width: width, Height: height }, &bg).unwrap();

        let viewport = RectF { X: 20.0, Y: 20.0, Width: width - 40.0, Height: height - 40.0 };
        let panel = SolidBrush::new(0xFF181B21).unwrap();
        g.fill_rounded_rect(viewport, 10.0, &panel).unwrap();
        let border = Pen::new(0xFF24272E, 1.0).unwrap();
        g.draw_rounded_rect(viewport, 10.0, &border).unwrap();

        let inner = RectF { X: viewport.X + 6.0, Y: viewport.Y + 6.0, Width: viewport.Width - 12.0, Height: viewport.Height - 12.0 };
        let content_height = ROW_COUNT as f32 * ROW_HEIGHT;
        let font = &self.font;
        let near = StringFormat::new().unwrap();
        near.set_align(StringAlignmentNear).unwrap();
        let mut scroll = self.scroll;
        scroll.show(g, inner, |g| {
            for i in 0..ROW_COUNT {
                let row_rect = RectF { X: inner.X, Y: inner.Y + i as f32 * ROW_HEIGHT, Width: inner.Width, Height: ROW_HEIGHT };
                if i % 2 == 0 {
                    let stripe = SolidBrush::new(0x14FFFFFF).unwrap();
                    g.fill_rect(row_rect, &stripe).ok();
                }
                let text_brush = SolidBrush::new(Color::rgb(0xEE, 0xF0, 0xF2).to_argb()).unwrap();
                g.draw_string(
                    &format!("Row {i} — C:\\FakeTool{i}\\payload.exe"),
                    font,
                    RectF { X: row_rect.X + 10.0, Y: row_rect.Y + 6.0, Width: row_rect.Width - 20.0, Height: 18.0 },
                    &near,
                    &text_brush,
                )
                .ok();
            }
        });
        scroll.finish(g, content_height);
        self.scroll = scroll;
    }

    fn hit_zone(&self, _x: f32, _y: f32, _width: f32, _height: f32) -> HitZone {
        HitZone::Client
    }
    fn on_mouse_move(&mut self, _x: f32, _y: f32, _width: f32, _height: f32) -> bool {
        false
    }
    fn on_mouse_down(&mut self, _x: f32, _y: f32, _width: f32, _height: f32) -> bool {
        false
    }
    fn on_mouse_up(&mut self, _x: f32, _y: f32, _width: f32, _height: f32) -> bool {
        false
    }
    fn on_mouse_wheel(&mut self, x: f32, y: f32, notches: f32, _width: f32, _height: f32) -> bool {
        if self.scroll.contains(x, y) {
            self.scroll.scroll_by_notches(notches, ROW_HEIGHT);
            true
        } else {
            false
        }
    }
}

fn main() -> windows::core::Result<()> {
    window::run(
        window::WindowConfig { title: "Scroll test".to_string(), size: (420, 320), min_size: (300, 200) },
        |_hwnd| DemoApp::new(),
    )
}
