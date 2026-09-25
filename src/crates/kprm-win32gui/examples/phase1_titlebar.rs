//! Phase 1 demo (see the plan): the real, reusable `window`/`gdiplus`
//! modules driving a title bar (drag via `WM_NCHITTEST`, hand-painted
//! minimize/close buttons with hover feedback) plus a disclaimer-style body
//! screen — everything `kprm`'s real `title_bar`/`ui_disclaimer` will be a
//! mechanical port of. Not shipped — run with
//! `cargo run -p kprm-win32gui --example phase1_titlebar`.

use kprm_win32gui::gdiplus::{
    argb, Font, FontFamily, Graphics, Pen, PrivateFontCollection, SolidBrush, StringFormat,
};
use kprm_win32gui::window::{self, AppWindow, HitZone, WindowConfig};
use windows::Win32::Graphics::GdiPlus::{
    FontStyleRegular, RectF, StringAlignmentCenter, StringAlignmentNear,
};

const BG: u32 = argb(255, 0x14, 0x16, 0x1b);
const BG_ELEVATED: u32 = argb(255, 0x1b, 0x1e, 0x24);
const BG_HOVER: u32 = argb(255, 0x26, 0x2a, 0x32);
const RED_BG: u32 = argb(255, 0x2e, 0x16, 0x15);
const BORDER_SOFT: u32 = argb(255, 0x24, 0x27, 0x2e);
const TEXT_1: u32 = argb(255, 0xee, 0xf0, 0xf2);
const TEXT_2: u32 = argb(255, 0x9a, 0x9f, 0xa8);
const GREEN: u32 = argb(255, 0x55, 0xc9, 0x8a);
const RED: u32 = argb(255, 0xe0, 0x52, 0x4a);

const TITLE_BAR_HEIGHT: f32 = 46.0;
const BTN_SIZE: f32 = 26.0;
const BTN_MARGIN_TOP: f32 = 10.0;
const BTN_RIGHT_MARGIN: f32 = 8.0;
const BTN_GAP: f32 = 4.0;

#[derive(PartialEq, Clone, Copy, Debug)]
enum Btn {
    Minimize,
    Close,
}

struct DemoApp {
    _fonts: PrivateFontCollection,
    _family: FontFamily,
    font_title: Font,
    font_body: Font,
    font_button: Font,
    hover_btn: Option<Btn>,
    pressed_btn: Option<Btn>,
    close_requested: bool,
    minimize_requested: bool,
}

impl DemoApp {
    fn new() -> Self {
        let fonts = PrivateFontCollection::new().expect("font collection");
        fonts
            .add_memory_font(include_bytes!("../../kprm/assets/fonts/SpaceGrotesk.ttf"))
            .expect("add embedded font");
        let family = FontFamily::from_name("Space Grotesk", &fonts).expect("font family");
        let font_title = Font::new(&family, 15.0, FontStyleRegular).expect("font");
        let font_body = Font::new(&family, 13.0, FontStyleRegular).expect("font");
        let font_button = Font::new(&family, 14.0, FontStyleRegular).expect("font");
        Self {
            _fonts: fonts,
            _family: family,
            font_title,
            font_body,
            font_button,
            hover_btn: None,
            pressed_btn: None,
            close_requested: false,
            minimize_requested: false,
        }
    }

    fn button_rect(&self, width: f32, btn: Btn) -> RectF {
        let close_x = width - BTN_RIGHT_MARGIN - BTN_SIZE;
        let minimize_x = close_x - BTN_GAP - BTN_SIZE;
        let x = match btn {
            Btn::Minimize => minimize_x,
            Btn::Close => close_x,
        };
        RectF { X: x, Y: BTN_MARGIN_TOP, Width: BTN_SIZE, Height: BTN_SIZE }
    }

    fn button_at(&self, width: f32, x: f32, y: f32) -> Option<Btn> {
        for btn in [Btn::Minimize, Btn::Close] {
            let r = self.button_rect(width, btn);
            if x >= r.X && x <= r.X + r.Width && y >= r.Y && y <= r.Y + r.Height {
                return Some(btn);
            }
        }
        None
    }
}

impl AppWindow for DemoApp {
    fn paint(&mut self, g: &Graphics, width: f32, height: f32) {
        let bg = SolidBrush::new(BG).unwrap();
        g.fill_rect(RectF { X: 0.0, Y: 0.0, Width: width, Height: height }, &bg)
            .unwrap();

        let titlebar_bg = SolidBrush::new(BG_ELEVATED).unwrap();
        g.fill_rect(
            RectF { X: 0.0, Y: 0.0, Width: width, Height: TITLE_BAR_HEIGHT },
            &titlebar_bg,
        )
        .unwrap();
        let border = Pen::new(BORDER_SOFT, 1.0).unwrap();
        g.draw_rounded_rect(
            RectF { X: 0.0, Y: 0.0, Width: width, Height: TITLE_BAR_HEIGHT },
            0.0,
            &border,
        )
        .ok();

        let text_1 = SolidBrush::new(TEXT_1).unwrap();
        let near = StringFormat::new().unwrap();
        near.set_align(StringAlignmentNear).unwrap();
        g.draw_string(
            "KpRm",
            &self.font_title,
            RectF { X: 16.0, Y: 14.0, Width: 200.0, Height: 20.0 },
            &near,
            &text_1,
        )
        .unwrap();

        for btn in [Btn::Minimize, Btn::Close] {
            let r = self.button_rect(width, btn);
            let is_hover = self.hover_btn == Some(btn);
            if is_hover {
                let fill_color = if btn == Btn::Close { RED_BG } else { BG_HOVER };
                let fill = SolidBrush::new(fill_color).unwrap();
                g.fill_rounded_rect(r, 6.0, &fill).unwrap();
            }
            let glyph_color = if is_hover && btn == Btn::Close { RED } else { TEXT_1 };
            let glyph_brush = SolidBrush::new(glyph_color).unwrap();
            let center = StringFormat::new().unwrap();
            center.set_align(StringAlignmentCenter).unwrap();
            let glyph = if btn == Btn::Minimize { "\u{2014}" } else { "\u{00D7}" };
            g.draw_string(glyph, &self.font_button, r, &center, &glyph_brush)
                .unwrap();
        }

        // Disclaimer-style body, standing in for `ui_disclaimer`.
        let title_brush = SolidBrush::new(TEXT_1).unwrap();
        let center = StringFormat::new().unwrap();
        center.set_align(StringAlignmentCenter).unwrap();
        g.draw_string(
            "Avertissement",
            &self.font_title,
            RectF { X: 0.0, Y: 120.0, Width: width, Height: 24.0 },
            &center,
            &title_brush,
        )
        .unwrap();

        let body_brush = SolidBrush::new(TEXT_2).unwrap();
        g.draw_string(
            "Ceci est un test visuel de la Phase 1 : barre de titre\ndeplacable, boutons reduire/fermer survolables, coins\narrondis et ombre DWM (Windows 11).",
            &self.font_body,
            RectF { X: 60.0, Y: 160.0, Width: width - 120.0, Height: 100.0 },
            &center,
            &body_brush,
        )
        .unwrap();

        let accept_brush = SolidBrush::new(GREEN).unwrap();
        g.draw_string(
            "(bouton Accepter simule — cliquez Fermer pour quitter)",
            &self.font_body,
            RectF { X: 60.0, Y: 260.0, Width: width - 120.0, Height: 40.0 },
            &center,
            &accept_brush,
        )
        .unwrap();
    }

    fn hit_zone(&self, x: f32, y: f32, width: f32, _height: f32) -> HitZone {
        if y < TITLE_BAR_HEIGHT && self.button_at(width, x, y).is_none() {
            HitZone::Caption
        } else {
            HitZone::Client
        }
    }

    fn on_mouse_move(&mut self, x: f32, y: f32, width: f32, _height: f32) -> bool {
        let new_hover = if y < TITLE_BAR_HEIGHT { self.button_at(width, x, y) } else { None };
        if new_hover != self.hover_btn {
            self.hover_btn = new_hover;
            true
        } else {
            false
        }
    }

    fn on_mouse_down(&mut self, _x: f32, _y: f32, _width: f32, _height: f32) -> bool {
        self.pressed_btn = self.hover_btn;
        false
    }

    fn on_mouse_up(&mut self, _x: f32, _y: f32, _width: f32, _height: f32) -> bool {
        if self.pressed_btn.is_some() && self.pressed_btn == self.hover_btn {
            match self.pressed_btn {
                Some(Btn::Close) => self.close_requested = true,
                Some(Btn::Minimize) => self.minimize_requested = true,
                None => {}
            }
        }
        self.pressed_btn = None;
        true
    }

    fn should_close(&mut self) -> bool {
        std::mem::take(&mut self.close_requested)
    }

    fn should_minimize(&mut self) -> bool {
        std::mem::take(&mut self.minimize_requested)
    }
}

fn main() -> windows::core::Result<()> {
    window::run(
        WindowConfig {
            title: "KpRm — Phase 1 demo".to_string(),
            size: (820, 680),
            min_size: (720, 480),
        },
        |_hwnd| DemoApp::new(),
    )
}
