//! Thin, RAII-safe wrappers around the GDI+ flat C API (`windows` crate's
//! `Win32_Graphics_Gdiplus` bindings), covering only what `kprm-win32gui`
//! needs: anti-aliased rounded-rect fill/stroke and text draw with an
//! embedded (private, in-process-only) TTF font.
//!
//! GDI+'s C API returns opaque object pointers the caller must explicitly
//! destroy (`GdipDelete*`) — every wrapper here owns exactly one such
//! pointer and frees it on `Drop`, so a leak would show up as a missing
//! `Drop` impl rather than a missing call site.

use core::ffi::c_void;
use windows::Win32::Foundation::BOOL;
use windows::Win32::Graphics::Gdi::HDC;
use windows::Win32::Graphics::GdiPlus as gp;
use windows::core::PCWSTR;

#[derive(Debug, Clone, Copy)]
pub struct GdiplusError(pub i32);

pub(crate) fn check(status: gp::Status) -> Result<(), GdiplusError> {
    if status == gp::Ok {
        Ok(())
    } else {
        Err(GdiplusError(status.0))
    }
}

pub const fn argb(a: u8, r: u8, g: u8, b: u8) -> u32 {
    ((a as u32) << 24) | ((r as u32) << 16) | ((g as u32) << 8) | (b as u32)
}

fn wide(s: &str) -> Vec<u16> {
    s.encode_utf16().chain(std::iter::once(0)).collect()
}

/// Process-wide GDI+ startup/shutdown token. Exactly one must be alive for
/// the lifetime of any other type in this module; keep it in the window's
/// state for as long as the window exists.
pub struct GdiplusToken(usize);

impl GdiplusToken {
    pub fn startup() -> Result<Self, GdiplusError> {
        unsafe {
            let input = gp::GdiplusStartupInput {
                GdiplusVersion: 1,
                DebugEventCallback: 0,
                SuppressBackgroundThread: BOOL(0),
                SuppressExternalCodecs: BOOL(0),
            };
            let mut token: usize = 0;
            check(gp::GdiplusStartup(
                &mut token,
                &input,
                std::ptr::null_mut(),
            ))?;
            Ok(Self(token))
        }
    }
}

impl Drop for GdiplusToken {
    fn drop(&mut self) {
        unsafe { gp::GdiplusShutdown(self.0) }
    }
}

/// A path tracing a rounded rectangle, built from 4 quarter-circle arcs —
/// the standard GDI+ technique (each `GdipAddPathArc` call implicitly draws
/// the straight connecting edge from the previous arc's endpoint).
struct RoundedRectPath(*mut gp::GpPath);

impl RoundedRectPath {
    fn new(rect: gp::RectF, radius: f32) -> Result<Self, GdiplusError> {
        unsafe {
            let mut path = std::ptr::null_mut();
            check(gp::GdipCreatePath(gp::FillModeAlternate, &mut path))?;
            let gp::RectF { X: x, Y: y, Width: w, Height: h } = rect;
            // A radius at or beyond half the smaller dimension should just
            // produce a pill/stadium shape (the common `radius: 999.0` "give
            // me a pill" idiom) — without this clamp, `x + w - d`/`y + h -
            // d` go negative and the four arcs end up wildly mispositioned
            // with oversized bounding boxes, drawing giant, wrong,
            // circle-like garbage instead of a rounded rect.
            let radius = radius.max(0.0).min(w.min(h) / 2.0);
            let d = radius * 2.0;
            check(gp::GdipAddPathArc(path, x, y, d, d, 180.0, 90.0))?;
            check(gp::GdipAddPathArc(path, x + w - d, y, d, d, 270.0, 90.0))?;
            check(gp::GdipAddPathArc(
                path,
                x + w - d,
                y + h - d,
                d,
                d,
                0.0,
                90.0,
            ))?;
            check(gp::GdipAddPathArc(path, x, y + h - d, d, d, 90.0, 90.0))?;
            check(gp::GdipClosePathFigure(path))?;
            Ok(Self(path))
        }
    }
}

impl Drop for RoundedRectPath {
    fn drop(&mut self) {
        unsafe {
            let _ = gp::GdipDeletePath(self.0);
        }
    }
}

/// A general-purpose, freely-built path — unlike the internal
/// [`RoundedRectPath`], this one is exposed so callers (`icons.rs`) can
/// stroke arbitrary line/bezier sequences, e.g. parsed from SVG path data.
pub struct Path(*mut gp::GpPath);

impl Path {
    pub fn new() -> Result<Self, GdiplusError> {
        unsafe {
            let mut path = std::ptr::null_mut();
            check(gp::GdipCreatePath(gp::FillModeAlternate, &mut path))?;
            Ok(Self(path))
        }
    }

    /// Begins a new disconnected subpath — the next `line_to`/`bezier_to`
    /// call starts here rather than being implicitly joined to wherever the
    /// path currently ends (GDI+'s default behavior for consecutive
    /// `GdipAddPath*` calls), matching an SVG path's `M`/`m` command.
    pub fn start_figure(&self) -> Result<(), GdiplusError> {
        unsafe { check(gp::GdipStartPathFigure(self.0)) }
    }

    pub fn line_to(&self, x1: f32, y1: f32, x2: f32, y2: f32) -> Result<(), GdiplusError> {
        unsafe { check(gp::GdipAddPathLine(self.0, x1, y1, x2, y2)) }
    }

    #[allow(clippy::too_many_arguments)]
    pub fn bezier_to(
        &self,
        x1: f32,
        y1: f32,
        x2: f32,
        y2: f32,
        x3: f32,
        y3: f32,
        x4: f32,
        y4: f32,
    ) -> Result<(), GdiplusError> {
        unsafe { check(gp::GdipAddPathBezier(self.0, x1, y1, x2, y2, x3, y3, x4, y4)) }
    }

    pub fn close_figure(&self) -> Result<(), GdiplusError> {
        unsafe { check(gp::GdipClosePathFigure(self.0)) }
    }
}

impl Drop for Path {
    fn drop(&mut self) {
        unsafe {
            let _ = gp::GdipDeletePath(self.0);
        }
    }
}

pub struct SolidBrush(*mut gp::GpSolidFill);

impl SolidBrush {
    pub fn new(argb: u32) -> Result<Self, GdiplusError> {
        unsafe {
            let mut brush = std::ptr::null_mut();
            check(gp::GdipCreateSolidFill(argb, &mut brush))?;
            Ok(Self(brush))
        }
    }
}

impl Drop for SolidBrush {
    fn drop(&mut self) {
        unsafe {
            let _ = gp::GdipDeleteBrush(self.0 as *mut gp::GpBrush);
        }
    }
}

pub struct Pen(*mut gp::GpPen);

impl Pen {
    pub fn new(argb: u32, width: f32) -> Result<Self, GdiplusError> {
        unsafe {
            let mut pen = std::ptr::null_mut();
            check(gp::GdipCreatePen1(argb, width, gp::UnitPixel, &mut pen))?;
            Ok(Self(pen))
        }
    }
}

impl Drop for Pen {
    fn drop(&mut self) {
        unsafe {
            let _ = gp::GdipDeletePen(self.0);
        }
    }
}

/// A private, process-local font collection loaded from embedded TTF bytes
/// (`GdipPrivateAddMemoryFont`) — never touches the system font registry.
pub struct PrivateFontCollection(*mut gp::GpFontCollection);

impl PrivateFontCollection {
    pub fn new() -> Result<Self, GdiplusError> {
        unsafe {
            let mut collection = std::ptr::null_mut();
            check(gp::GdipNewPrivateFontCollection(&mut collection))?;
            Ok(Self(collection))
        }
    }

    /// `bytes` must stay alive for at least as long as fonts are resolved
    /// from this collection — GDI+ keeps referring to the memory block
    /// rather than copying it up front. Callers should pass a `'static`
    /// `include_bytes!` slice.
    pub fn add_memory_font(&self, bytes: &'static [u8]) -> Result<(), GdiplusError> {
        unsafe {
            check(gp::GdipPrivateAddMemoryFont(
                self.0,
                bytes.as_ptr() as *const c_void,
                bytes.len() as i32,
            ))
        }
    }
}

impl Drop for PrivateFontCollection {
    fn drop(&mut self) {
        unsafe {
            let mut ptr = self.0;
            let _ = gp::GdipDeletePrivateFontCollection(&mut ptr);
        }
    }
}

pub struct FontFamily(*mut gp::GpFontFamily);

impl FontFamily {
    pub fn from_name(name: &str, collection: &PrivateFontCollection) -> Result<Self, GdiplusError> {
        let name = wide(name);
        unsafe {
            let mut family = std::ptr::null_mut();
            check(gp::GdipCreateFontFamilyFromName(
                PCWSTR(name.as_ptr()),
                collection.0,
                &mut family,
            ))?;
            Ok(Self(family))
        }
    }
}

impl Drop for FontFamily {
    fn drop(&mut self) {
        unsafe {
            let _ = gp::GdipDeleteFontFamily(self.0);
        }
    }
}

pub struct Font(*mut gp::GpFont);

impl Font {
    /// `style` is one of GDI+'s `FontStyle*` constants (`FontStyleRegular`,
    /// `FontStyleBold`, ...) — `kprm`'s theme uses GDI+'s own synthetic
    /// bold on the single embedded Regular weight, matching today's `egui`
    /// faux-bold rather than shipping separate bold TTFs.
    pub fn new(family: &FontFamily, em_size_px: f32, style: gp::FontStyle) -> Result<Self, GdiplusError> {
        unsafe {
            let mut font = std::ptr::null_mut();
            check(gp::GdipCreateFont(
                family.0,
                em_size_px,
                style.0,
                gp::UnitPixel,
                &mut font,
            ))?;
            Ok(Self(font))
        }
    }
}

impl Drop for Font {
    fn drop(&mut self) {
        unsafe {
            let _ = gp::GdipDeleteFont(self.0);
        }
    }
}

pub struct StringFormat(*mut gp::GpStringFormat);

impl StringFormat {
    pub fn new() -> Result<Self, GdiplusError> {
        unsafe {
            let mut format = std::ptr::null_mut();
            check(gp::GdipCreateStringFormat(0, 0, &mut format))?;
            Ok(Self(format))
        }
    }

    pub fn set_align(&self, align: gp::StringAlignment) -> Result<(), GdiplusError> {
        unsafe { check(gp::GdipSetStringFormatAlign(self.0, align)) }
    }

    /// The vertical counterpart of [`Self::set_align`] — GDI+ defaults
    /// this to `Near` (top), so a single-line label drawn into a rect
    /// taller than the text (any button/tab/pill) sits at the top of it
    /// unless this is also set to `Center`.
    pub fn set_line_align(&self, align: gp::StringAlignment) -> Result<(), GdiplusError> {
        unsafe { check(gp::GdipSetStringFormatLineAlign(self.0, align)) }
    }
}

impl Drop for StringFormat {
    fn drop(&mut self) {
        unsafe {
            let _ = gp::GdipDeleteStringFormat(self.0);
        }
    }
}

/// A `GpGraphics` bound to a device context — created fresh per paint from
/// the (offscreen, double-buffered) DC, never cached across frames.
pub struct Graphics(*mut gp::GpGraphics);

impl Graphics {
    pub(crate) fn as_raw(&self) -> *mut gp::GpGraphics {
        self.0
    }

    pub fn from_hdc(hdc: HDC) -> Result<Self, GdiplusError> {
        unsafe {
            let mut graphics = std::ptr::null_mut();
            check(gp::GdipCreateFromHDC(hdc, &mut graphics))?;
            Ok(Self(graphics))
        }
    }

    pub fn set_smoothing_antialias(&self) -> Result<(), GdiplusError> {
        unsafe { check(gp::GdipSetSmoothingMode(self.0, gp::SmoothingModeAntiAlias)) }
    }

    pub fn set_text_rendering_cleartype(&self) -> Result<(), GdiplusError> {
        unsafe {
            check(gp::GdipSetTextRenderingHint(
                self.0,
                gp::TextRenderingHintClearTypeGridFit,
            ))
        }
    }

    /// Scales every subsequent draw call on this `Graphics` by `scale` —
    /// the single place DPI scaling happens: callers (the app's `paint`)
    /// work entirely in logical (96-DPI) pixels, matching the values
    /// already baked into the ported `egui` layout constants, and this
    /// world-transform makes those land on the right physical pixels on a
    /// scaled display without every draw call having to multiply by the
    /// current DPI itself.
    pub fn set_scale(&self, scale: f32) -> Result<(), GdiplusError> {
        unsafe { check(gp::GdipScaleWorldTransform(self.0, scale, scale, gp::MatrixOrderPrepend)) }
    }

    pub fn draw_line(&self, x1: f32, y1: f32, x2: f32, y2: f32, pen: &Pen) -> Result<(), GdiplusError> {
        unsafe { check(gp::GdipDrawLine(self.0, pen.0, x1, y1, x2, y2)) }
    }

    pub fn draw_path(&self, path: &Path, pen: &Pen) -> Result<(), GdiplusError> {
        unsafe { check(gp::GdipDrawPath(self.0, pen.0, path.0)) }
    }

    pub fn draw_ellipse(&self, x: f32, y: f32, width: f32, height: f32, pen: &Pen) -> Result<(), GdiplusError> {
        unsafe { check(gp::GdipDrawEllipse(self.0, pen.0, x, y, width, height)) }
    }

    /// Restricts subsequent drawing to `rect` — replaces any previous clip
    /// (this crate never nests clip regions today; a scroll area inside
    /// another scroll area would need `CombineModeIntersect` instead).
    /// Pair with [`Graphics::reset_clip`] once done.
    pub fn set_clip_rect(&self, rect: gp::RectF) -> Result<(), GdiplusError> {
        unsafe {
            check(gp::GdipSetClipRect(
                self.0,
                rect.X,
                rect.Y,
                rect.Width,
                rect.Height,
                gp::CombineModeReplace,
            ))
        }
    }

    pub fn reset_clip(&self) -> Result<(), GdiplusError> {
        unsafe { check(gp::GdipResetClip(self.0)) }
    }

    /// Composes a translation onto the current world transform (which
    /// already carries the DPI scale — see [`Graphics::set_scale`]); call
    /// again with the negated `dx`/`dy` to undo it exactly once the
    /// translated drawing is done, rather than resetting the whole
    /// transform (which would also drop the DPI scale).
    pub fn translate(&self, dx: f32, dy: f32) -> Result<(), GdiplusError> {
        unsafe { check(gp::GdipTranslateWorldTransform(self.0, dx, dy, gp::MatrixOrderPrepend)) }
    }

    /// Snapshots the full graphics state (clip *and* transform together) —
    /// paired with [`Graphics::restore`], this is what lets
    /// [`crate::scroll::ScrollState::show`] nest correctly: restoring
    /// undoes exactly this call's clip+translate, leaving whatever an
    /// *enclosing* scroll area had already set up intact, unlike
    /// unconditionally resetting the clip.
    pub fn save(&self) -> Result<u32, GdiplusError> {
        unsafe {
            let mut state = 0u32;
            check(gp::GdipSaveGraphics(self.0, &mut state))?;
            Ok(state)
        }
    }

    pub fn restore(&self, state: u32) -> Result<(), GdiplusError> {
        unsafe { check(gp::GdipRestoreGraphics(self.0, state)) }
    }

    pub fn fill_rect(&self, rect: gp::RectF, brush: &SolidBrush) -> Result<(), GdiplusError> {
        unsafe {
            check(gp::GdipFillRectangle(
                self.0,
                brush.0 as *mut gp::GpBrush,
                rect.X,
                rect.Y,
                rect.Width,
                rect.Height,
            ))
        }
    }

    pub fn fill_rounded_rect(
        &self,
        rect: gp::RectF,
        radius: f32,
        brush: &SolidBrush,
    ) -> Result<(), GdiplusError> {
        let path = RoundedRectPath::new(rect, radius)?;
        unsafe { check(gp::GdipFillPath(self.0, brush.0 as *mut gp::GpBrush, path.0)) }
    }

    pub fn draw_rounded_rect(
        &self,
        rect: gp::RectF,
        radius: f32,
        pen: &Pen,
    ) -> Result<(), GdiplusError> {
        let path = RoundedRectPath::new(rect, radius)?;
        unsafe { check(gp::GdipDrawPath(self.0, pen.0, path.0)) }
    }

    /// The natural (single-line, unwrapped) width of `text` set in `font` —
    /// used to size hit-test rects for text-only widgets (tab labels,
    /// buttons sized to their content) rather than hardcoding pixel widths.
    pub fn measure_line_width(&self, text: &str, font: &Font) -> Result<f32, GdiplusError> {
        let wide = wide(text);
        let format = StringFormat::new()?;
        unsafe {
            let layout = gp::RectF { X: 0.0, Y: 0.0, Width: 9999.0, Height: 9999.0 };
            let mut bounds = gp::RectF::default();
            let mut fitted = 0i32;
            let mut lines = 0i32;
            check(gp::GdipMeasureString(
                self.0,
                PCWSTR(wide.as_ptr()),
                -1,
                font.0,
                &layout,
                format.0,
                &mut bounds,
                &mut fitted,
                &mut lines,
            ))?;
            Ok(bounds.Width)
        }
    }

    pub fn draw_string(
        &self,
        text: &str,
        font: &Font,
        layout: gp::RectF,
        format: &StringFormat,
        brush: &SolidBrush,
    ) -> Result<(), GdiplusError> {
        let text = wide(text);
        unsafe {
            check(gp::GdipDrawString(
                self.0,
                PCWSTR(text.as_ptr()),
                -1,
                font.0,
                &layout,
                format.0,
                brush.0 as *mut gp::GpBrush,
            ))
        }
    }
}

impl Drop for Graphics {
    fn drop(&mut self) {
        unsafe {
            let _ = gp::GdipDeleteGraphics(self.0);
        }
    }
}
