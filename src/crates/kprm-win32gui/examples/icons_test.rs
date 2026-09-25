//! Visual smoke test for `icons.rs`, especially the SVG arc-to-bezier path
//! — draws each icon used by `kprm`'s Automatic tab in a grid. Not shipped;
//! run with `cargo run -p kprm-win32gui --example icons_test`.

use kprm_win32gui::color::Color;
use kprm_win32gui::gdiplus::{Graphics, SolidBrush};
use kprm_win32gui::icons::{Element, Icon};
use kprm_win32gui::window::{self, AppWindow, HitZone};
use windows::Win32::Graphics::GdiPlus::RectF;

const CHECK: Icon = Icon(&[Element::Polyline(&[(5.0, 12.0), (10.0, 17.0), (19.0, 6.0)])]);
const TRASH: Icon = Icon(&[
    Element::Path("M6 7h12"),
    Element::Path("M9 7V5a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v2"),
    Element::Path("M7 7l1 12a2 2 0 0 0 2 2h4a2 2 0 0 0 2-2l1-12"),
]);
const SAVE: Icon = Icon(&[
    Element::Path("M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"),
    Element::Polyline(&[(17.0, 21.0), (17.0, 13.0), (7.0, 13.0), (7.0, 21.0)]),
    Element::Polyline(&[(7.0, 3.0), (7.0, 8.0), (15.0, 8.0)]),
]);
const UNDO: Icon = Icon(&[
    Element::Path("M3 12a9 9 0 1 0 3-6.7L3 8"),
    Element::Polyline(&[(3.0, 3.0), (3.0, 8.0), (8.0, 8.0)]),
]);
const CIRCLE_PLUS: Icon = Icon(&[
    Element::Circle { cx: 12.0, cy: 12.0, r: 9.0 },
    Element::Line(12.0, 8.0, 12.0, 16.0),
    Element::Line(8.0, 12.0, 16.0, 12.0),
]);
const LOCK: Icon = Icon(&[
    Element::Rect { x: 4.0, y: 11.0, w: 16.0, h: 10.0, rx: 2.0 },
    Element::Path("M7.5 11V7.5a4.5 4.5 0 0 1 9 0V11"),
]);
const SLIDERS: Icon = Icon(&[
    Element::Line(5.0, 21.0, 5.0, 14.0),
    Element::Line(5.0, 10.0, 5.0, 3.0),
    Element::Circle { cx: 5.0, cy: 12.0, r: 2.0 },
    Element::Line(12.0, 21.0, 12.0, 12.0),
    Element::Line(12.0, 8.0, 12.0, 3.0),
    Element::Circle { cx: 12.0, cy: 10.0, r: 2.0 },
    Element::Line(19.0, 21.0, 19.0, 16.0),
    Element::Line(19.0, 12.0, 19.0, 3.0),
    Element::Circle { cx: 19.0, cy: 14.0, r: 2.0 },
]);

struct DemoApp;

impl AppWindow for DemoApp {
    fn paint(&mut self, g: &Graphics, width: f32, height: f32) {
        let bg = SolidBrush::new(0xFF14161B).unwrap();
        g.fill_rect(RectF { X: 0.0, Y: 0.0, Width: width, Height: height }, &bg).unwrap();

        let icons: &[(&str, &Icon)] =
            &[("check", &CHECK), ("trash", &TRASH), ("save", &SAVE), ("undo", &UNDO), ("circle+", &CIRCLE_PLUS), ("lock", &LOCK), ("sliders", &SLIDERS)];

        let white = Color::rgb(0xEE, 0xF0, 0xF2);
        let cell = 90.0;
        for (i, (_name, icon)) in icons.iter().enumerate() {
            let x = 30.0 + (i as f32) * cell;
            let dest = RectF { X: x, Y: 40.0, Width: 48.0, Height: 48.0 };
            let panel = SolidBrush::new(0xFF181B21).unwrap();
            g.fill_rounded_rect(dest, 8.0, &panel).unwrap();
            icon.draw(g, dest, white, 1.8).unwrap();
        }
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
}

fn main() -> windows::core::Result<()> {
    window::run(
        window::WindowConfig { title: "Icons test".to_string(), size: (700, 150), min_size: (700, 150) },
        |_hwnd| DemoApp,
    )
}
