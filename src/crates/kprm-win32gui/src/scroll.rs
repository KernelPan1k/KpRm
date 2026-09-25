//! A scrollable region: clip + world-transform translate for the content
//! (`Graphics::set_clip_rect`/`translate`), a hand-painted thumb, and wheel
//! routing by cursor position — the toolkit's answer to `egui::ScrollArea`,
//! since nothing here can lean on a native scrollbar control without
//! visually clashing with the rest of the hand-drawn theme (see the
//! rewrite plan's architecture section).

use crate::color::Color;
use crate::gdiplus::{Graphics, SolidBrush};
use windows::Win32::Graphics::GdiPlus::RectF;

const THUMB_WIDTH: f32 = 4.0;
const THUMB_MARGIN: f32 = 2.0;
/// Windows reports wheel deltas in multiples of `WHEEL_DELTA` (120) and
/// [`crate::window::AppWindow::on_mouse_wheel`] already divides that out —
/// this is how many rows one "notch" scrolls.
pub const LINES_PER_NOTCH: f32 = 3.0;

/// Persistent per-scroll-area state — one instance per independently
/// scrollable region (e.g. the Custom tab's result list has one; the
/// Extra Tools tab will need one for its outer scroll and another for its
/// nested backup list).
#[derive(Default, Clone, Copy)]
pub struct ScrollState {
    pub offset: f32,
    /// The viewport rect and content height from the *last* paint, cached
    /// so wheel/hit-testing (which run outside of paint, with no
    /// `Graphics` and no fresh layout pass) can still route correctly.
    pub last_viewport: RectF,
    pub last_content_height: f32,
}

impl ScrollState {
    pub fn clamp(&mut self, content_height: f32, viewport_height: f32) {
        let max = (content_height - viewport_height).max(0.0);
        self.offset = self.offset.clamp(0.0, max);
    }

    /// `wheel_notches` is already in "one mouse-wheel notch" units (see
    /// [`crate::window::AppWindow::on_mouse_wheel`]); positive scrolls
    /// down, matching Windows' own convention of a positive delta meaning
    /// the wheel moved away from the user (scroll up) — so this negates it.
    pub fn scroll_by_notches(&mut self, wheel_notches: f32, row_height: f32) {
        self.offset -= wheel_notches * LINES_PER_NOTCH * row_height;
        self.clamp(self.last_content_height, self.last_viewport.Height);
    }

    pub fn contains(&self, x: f32, y: f32) -> bool {
        x >= self.last_viewport.X
            && x <= self.last_viewport.X + self.last_viewport.Width
            && y >= self.last_viewport.Y
            && y <= self.last_viewport.Y + self.last_viewport.Height
    }

    /// Runs `draw_content` with the graphics clipped to `viewport` and
    /// translated so the content scrolls — `draw_content` draws as if
    /// `viewport.Y` were the top of an unscrolled, unclipped page, and
    /// returns the content's total natural height (used to clamp the
    /// offset and size the thumb).
    pub fn show(&mut self, g: &Graphics, viewport: RectF, draw_content: impl FnOnce(&Graphics)) {
        self.last_viewport = viewport;
        g.set_clip_rect(viewport).ok();
        g.translate(0.0, -self.offset).ok();

        draw_content(g);

        g.translate(0.0, self.offset).ok();
        g.reset_clip().ok();
    }

    /// Call once the content's real height is known (typically right after
    /// [`ScrollState::show`], once the caller has counted its own rows) to
    /// clamp the offset and draw the thumb, if the content overflows.
    pub fn finish(&mut self, g: &Graphics, content_height: f32) {
        self.last_content_height = content_height;
        self.clamp(content_height, self.last_viewport.Height);
        if content_height <= self.last_viewport.Height {
            return;
        }
        let viewport = self.last_viewport;
        let track_h = viewport.Height;
        let thumb_h = (track_h * (viewport.Height / content_height)).max(20.0);
        let max_offset = content_height - viewport.Height;
        let thumb_y = if max_offset > 0.0 {
            viewport.Y + (track_h - thumb_h) * (self.offset / max_offset)
        } else {
            viewport.Y
        };
        let thumb_rect = RectF {
            X: viewport.X + viewport.Width - THUMB_WIDTH - THUMB_MARGIN,
            Y: thumb_y,
            Width: THUMB_WIDTH,
            Height: thumb_h,
        };
        let brush = SolidBrush::new(Color::rgba(0x52, 0x59, 0x6a, 200).to_argb()).unwrap();
        g.fill_rounded_rect(thumb_rect, THUMB_WIDTH / 2.0, &brush).ok();
    }
}
