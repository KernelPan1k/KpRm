//! Renders the small Lucide-style line icons used throughout `kprm` (tab
//! icons, action-row badges, ...) from the exact SVG `d`/`points`/`cx,cy,r`
//! data copied out of the `docs/design/*.dc.html` mockups — vector, not
//! pre-rendered PNGs, so they stay crisp at any DPI and recolor exactly
//! like any other stroke in the app.
//!
//! Every icon here is defined against a 24×24 SVG `viewBox`, matching the
//! mockups; [`Icon::draw`] maps that space onto whatever destination rect
//! the caller gives it.

use crate::color::Color;
use crate::gdiplus::{GdiplusError, Graphics, Path, Pen};
use windows::Win32::Graphics::GdiPlus::RectF;

/// One drawable piece of an icon, in 24×24 viewBox units — a direct
/// transcription of one SVG child element.
pub enum Element {
    /// An SVG `<path d="...">` — parsed at draw time (these are tiny, a
    /// handful of segments each, so re-parsing per paint costs nothing
    /// worth caching, consistent with the rest of this crate's "recompute
    /// every frame" design).
    Path(&'static str),
    Polyline(&'static [(f32, f32)]),
    Circle { cx: f32, cy: f32, r: f32 },
    Line(f32, f32, f32, f32),
    Rect { x: f32, y: f32, w: f32, h: f32, rx: f32 },
}

pub struct Icon(pub &'static [Element]);

impl Icon {
    pub fn draw(&self, g: &Graphics, dest: RectF, color: Color, stroke_width: f32) -> Result<(), GdiplusError> {
        let sx = dest.Width / 24.0;
        let sy = dest.Height / 24.0;
        let map = |x: f32, y: f32| (dest.X + x * sx, dest.Y + y * sy);
        // SVG strokes scale with the shape; average the two axes since our
        // icons are always drawn into a square-ish rect.
        let pen = Pen::new(color.to_argb(), stroke_width * (sx + sy) / 2.0)?;

        for element in self.0 {
            match element {
                Element::Line(x1, y1, x2, y2) => {
                    let (x1, y1) = map(*x1, *y1);
                    let (x2, y2) = map(*x2, *y2);
                    g.draw_line(x1, y1, x2, y2, &pen)?;
                }
                Element::Polyline(points) => {
                    for pair in points.windows(2) {
                        let (x1, y1) = map(pair[0].0, pair[0].1);
                        let (x2, y2) = map(pair[1].0, pair[1].1);
                        g.draw_line(x1, y1, x2, y2, &pen)?;
                    }
                }
                Element::Circle { cx, cy, r } => {
                    let (x, y) = map(cx - r, cy - r);
                    g.draw_ellipse(x, y, r * 2.0 * sx, r * 2.0 * sy, &pen)?;
                }
                Element::Rect { x, y, w, h, rx: _ } => {
                    // The tiny corner radii in these icons round to well
                    // under a physical pixel at the sizes this app draws
                    // icons at — a plain rect is visually identical here.
                    let (x1, y1) = map(*x, *y);
                    let (x2, y2) = map(x + w, y + h);
                    g.draw_line(x1, y1, x2, y1, &pen)?;
                    g.draw_line(x2, y1, x2, y2, &pen)?;
                    g.draw_line(x2, y2, x1, y2, &pen)?;
                    g.draw_line(x1, y2, x1, y1, &pen)?;
                }
                Element::Path(d) => {
                    let path = Path::new()?;
                    let mut started = false;
                    for segment in parse_path(d) {
                        match segment {
                            Segment::Move => {
                                path.start_figure()?;
                                started = true;
                            }
                            Segment::Line(x1, y1, x2, y2) => {
                                let (x1, y1) = map(x1, y1);
                                let (x2, y2) = map(x2, y2);
                                path.line_to(x1, y1, x2, y2)?;
                            }
                            Segment::Cubic(x1, y1, cx1, cy1, cx2, cy2, x2, y2) => {
                                let (x1, y1) = map(x1, y1);
                                let (cx1, cy1) = map(cx1, cy1);
                                let (cx2, cy2) = map(cx2, cy2);
                                let (x2, y2) = map(x2, y2);
                                path.bezier_to(x1, y1, cx1, cy1, cx2, cy2, x2, y2)?;
                            }
                            Segment::Close => {
                                path.close_figure()?;
                            }
                        }
                    }
                    if started {
                        g.draw_path(&path, &pen)?;
                    }
                }
            }
        }
        Ok(())
    }
}

/// A parsed path segment, already carrying its own start point (so
/// building the GDI+ path never needs an implicit "current point" of its
/// own) — `Move` is a no-op marker kept only so `Icon::draw` knows to
/// `start_figure()`.
enum Segment {
    Move,
    Line(f32, f32, f32, f32),
    #[allow(clippy::type_complexity)]
    Cubic(f32, f32, f32, f32, f32, f32, f32, f32),
    Close,
}

struct Tokenizer<'a> {
    bytes: &'a [u8],
    pos: usize,
}

impl<'a> Tokenizer<'a> {
    fn new(s: &'a str) -> Self {
        Self { bytes: s.as_bytes(), pos: 0 }
    }

    fn skip_sep(&mut self) {
        while self.pos < self.bytes.len() && matches!(self.bytes[self.pos], b' ' | b',' | b'\n' | b'\t' | b'\r') {
            self.pos += 1;
        }
    }

    fn peek_command(&mut self) -> Option<char> {
        self.skip_sep();
        self.bytes.get(self.pos).map(|&b| b as char).filter(|c| c.is_ascii_alphabetic())
    }

    fn next_command(&mut self) {
        self.pos += 1;
    }

    fn next_number(&mut self) -> Option<f32> {
        self.skip_sep();
        let start = self.pos;
        if matches!(self.bytes.get(self.pos), Some(b'-' | b'+')) {
            self.pos += 1;
        }
        let mut has_digits = false;
        while matches!(self.bytes.get(self.pos), Some(b'0'..=b'9')) {
            self.pos += 1;
            has_digits = true;
        }
        if self.bytes.get(self.pos) == Some(&b'.') {
            self.pos += 1;
            while matches!(self.bytes.get(self.pos), Some(b'0'..=b'9')) {
                self.pos += 1;
                has_digits = true;
            }
        }
        if !has_digits {
            self.pos = start;
            return None;
        }
        std::str::from_utf8(&self.bytes[start..self.pos]).ok()?.parse().ok()
    }

    /// Arc flags (`large-arc-flag`/`sweep-flag`) are single `0`/`1` digits
    /// that SVG allows to run together with no separator at all.
    fn next_flag(&mut self) -> Option<bool> {
        self.skip_sep();
        match self.bytes.get(self.pos) {
            Some(b'0') => {
                self.pos += 1;
                Some(false)
            }
            Some(b'1') => {
                self.pos += 1;
                Some(true)
            }
            _ => None,
        }
    }
}

/// Parses a subset of the SVG path `d` mini-language (`M`/`L`/`H`/`V`/`C`/
/// `S`/`Q`/`T`/`A`/`Z`, both cases) into flattened line/cubic-bezier
/// segments — arcs (`A`) are converted to bezier segments via
/// [`arc_to_beziers`]. Every icon this app embeds uses zero x-axis
/// rotation on its arcs, which [`arc_to_beziers`] assumes.
fn parse_path(d: &str) -> Vec<Segment> {
    let mut t = Tokenizer::new(d);
    let mut segs = Vec::new();
    let (mut cx, mut cy) = (0.0f32, 0.0f32);
    let (mut start_x, mut start_y) = (0.0f32, 0.0f32);
    let mut last_cubic_ctrl: Option<(f32, f32)> = None;
    let mut last_quad_ctrl: Option<(f32, f32)> = None;
    let mut cmd: Option<char> = None;

    loop {
        if let Some(c) = t.peek_command() {
            cmd = Some(c);
            t.next_command();
        }
        let Some(c) = cmd else { break };
        match c {
            'M' | 'm' => {
                let (Some(x), Some(y)) = (t.next_number(), t.next_number()) else { break };
                let (nx, ny) = if c == 'm' { (cx + x, cy + y) } else { (x, y) };
                segs.push(Segment::Move);
                cx = nx;
                cy = ny;
                start_x = nx;
                start_y = ny;
                last_cubic_ctrl = None;
                last_quad_ctrl = None;
                cmd = Some(if c == 'm' { 'l' } else { 'L' });
            }
            'L' | 'l' => {
                let (Some(x), Some(y)) = (t.next_number(), t.next_number()) else { break };
                let (nx, ny) = if c == 'l' { (cx + x, cy + y) } else { (x, y) };
                segs.push(Segment::Line(cx, cy, nx, ny));
                cx = nx;
                cy = ny;
                last_cubic_ctrl = None;
                last_quad_ctrl = None;
            }
            'H' | 'h' => {
                let Some(x) = t.next_number() else { break };
                let nx = if c == 'h' { cx + x } else { x };
                segs.push(Segment::Line(cx, cy, nx, cy));
                cx = nx;
                last_cubic_ctrl = None;
                last_quad_ctrl = None;
            }
            'V' | 'v' => {
                let Some(y) = t.next_number() else { break };
                let ny = if c == 'v' { cy + y } else { y };
                segs.push(Segment::Line(cx, cy, cx, ny));
                cy = ny;
                last_cubic_ctrl = None;
                last_quad_ctrl = None;
            }
            'C' | 'c' => {
                let Some(v) = read_n(&mut t, 6) else { break };
                let (x1, y1, x2, y2, x, y) = if c == 'c' {
                    (cx + v[0], cy + v[1], cx + v[2], cy + v[3], cx + v[4], cy + v[5])
                } else {
                    (v[0], v[1], v[2], v[3], v[4], v[5])
                };
                segs.push(Segment::Cubic(cx, cy, x1, y1, x2, y2, x, y));
                last_cubic_ctrl = Some((x2, y2));
                last_quad_ctrl = None;
                cx = x;
                cy = y;
            }
            'S' | 's' => {
                let Some(v) = read_n(&mut t, 4) else { break };
                let (x2, y2, x, y) = if c == 's' {
                    (cx + v[0], cy + v[1], cx + v[2], cy + v[3])
                } else {
                    (v[0], v[1], v[2], v[3])
                };
                let (x1, y1) = last_cubic_ctrl.map(|(px, py)| (2.0 * cx - px, 2.0 * cy - py)).unwrap_or((cx, cy));
                segs.push(Segment::Cubic(cx, cy, x1, y1, x2, y2, x, y));
                last_cubic_ctrl = Some((x2, y2));
                last_quad_ctrl = None;
                cx = x;
                cy = y;
            }
            'Q' | 'q' => {
                let Some(v) = read_n(&mut t, 4) else { break };
                let (qx, qy, x, y) = if c == 'q' {
                    (cx + v[0], cy + v[1], cx + v[2], cy + v[3])
                } else {
                    (v[0], v[1], v[2], v[3])
                };
                let x1 = cx + 2.0 / 3.0 * (qx - cx);
                let y1 = cy + 2.0 / 3.0 * (qy - cy);
                let x2 = x + 2.0 / 3.0 * (qx - x);
                let y2 = y + 2.0 / 3.0 * (qy - y);
                segs.push(Segment::Cubic(cx, cy, x1, y1, x2, y2, x, y));
                last_quad_ctrl = Some((qx, qy));
                last_cubic_ctrl = None;
                cx = x;
                cy = y;
            }
            'T' | 't' => {
                let Some(v) = read_n(&mut t, 2) else { break };
                let (x, y) = if c == 't' { (cx + v[0], cy + v[1]) } else { (v[0], v[1]) };
                let (qx, qy) = last_quad_ctrl.map(|(px, py)| (2.0 * cx - px, 2.0 * cy - py)).unwrap_or((cx, cy));
                let x1 = cx + 2.0 / 3.0 * (qx - cx);
                let y1 = cy + 2.0 / 3.0 * (qy - cy);
                let x2 = x + 2.0 / 3.0 * (qx - x);
                let y2 = y + 2.0 / 3.0 * (qy - y);
                segs.push(Segment::Cubic(cx, cy, x1, y1, x2, y2, x, y));
                last_quad_ctrl = Some((qx, qy));
                last_cubic_ctrl = None;
                cx = x;
                cy = y;
            }
            'A' | 'a' => {
                let rx = t.next_number();
                let ry = t.next_number();
                let _rot = t.next_number();
                let large = t.next_flag();
                let sweep = t.next_flag();
                let x = t.next_number();
                let y = t.next_number();
                let (Some(rx), Some(ry), Some(large), Some(sweep), Some(x), Some(y)) = (rx, ry, large, sweep, x, y)
                else {
                    break;
                };
                let (nx, ny) = if c == 'a' { (cx + x, cy + y) } else { (x, y) };
                let mut beziers = Vec::new();
                arc_to_beziers(cx, cy, rx, ry, large, sweep, nx, ny, &mut beziers);
                for b in beziers {
                    segs.push(Segment::Cubic(b[0], b[1], b[2], b[3], b[4], b[5], b[6], b[7]));
                }
                cx = nx;
                cy = ny;
                last_cubic_ctrl = None;
                last_quad_ctrl = None;
            }
            'Z' | 'z' => {
                segs.push(Segment::Close);
                cx = start_x;
                cy = start_y;
                cmd = None;
                continue;
            }
            _ => break,
        }
    }
    segs
}

fn read_n(t: &mut Tokenizer, n: usize) -> Option<Vec<f32>> {
    let mut v = Vec::with_capacity(n);
    for _ in 0..n {
        v.push(t.next_number()?);
    }
    Some(v)
}

/// SVG elliptical-arc-to-bezier conversion (endpoint parameterization, per
/// the SVG 1.1 spec appendix), **assuming zero x-axis rotation** — true of
/// every icon embedded in this app. Pushes one or more cubic beziers, each
/// `[x0,y0, c1x,c1y, c2x,c2y, x,y]`, covering at most ~90° of arc apiece
/// (the standard bezier arc approximation only stays visually accurate
/// under about that span).
#[allow(clippy::too_many_arguments)]
fn arc_to_beziers(x0: f32, y0: f32, rx: f32, ry: f32, large_arc: bool, sweep: bool, x: f32, y: f32, out: &mut Vec<[f32; 8]>) {
    if (x0 - x).abs() < 1e-6 && (y0 - y).abs() < 1e-6 {
        return;
    }
    if rx.abs() < 1e-6 || ry.abs() < 1e-6 {
        out.push([x0, y0, x0, y0, x, y, x, y]);
        return;
    }
    let (mut rx, mut ry) = (rx.abs(), ry.abs());

    let x1p = (x0 - x) / 2.0;
    let y1p = (y0 - y) / 2.0;

    let lambda = (x1p * x1p) / (rx * rx) + (y1p * y1p) / (ry * ry);
    if lambda > 1.0 {
        let s = lambda.sqrt();
        rx *= s;
        ry *= s;
    }

    let sign: f32 = if large_arc != sweep { 1.0 } else { -1.0 };
    let num = (rx * rx * ry * ry - rx * rx * y1p * y1p - ry * ry * x1p * x1p).max(0.0);
    let den = rx * rx * y1p * y1p + ry * ry * x1p * x1p;
    let co = if den > 1e-9 { sign * (num / den).sqrt() } else { 0.0 };
    let cxp = co * (rx * y1p / ry);
    let cyp = co * (-ry * x1p / rx);
    let cx = cxp + (x0 + x) / 2.0;
    let cy = cyp + (y0 + y) / 2.0;

    let angle = |ux: f32, uy: f32, vx: f32, vy: f32| -> f32 {
        let dot = ux * vx + uy * vy;
        let len = ((ux * ux + uy * uy) * (vx * vx + vy * vy)).sqrt();
        let mut a = (dot / len).clamp(-1.0, 1.0).acos();
        if ux * vy - uy * vx < 0.0 {
            a = -a;
        }
        a
    };
    let theta1 = angle(1.0, 0.0, (x1p - cxp) / rx, (y1p - cyp) / ry);
    let mut dtheta = angle((x1p - cxp) / rx, (y1p - cyp) / ry, (-x1p - cxp) / rx, (-y1p - cyp) / ry);
    if !sweep && dtheta > 0.0 {
        dtheta -= 2.0 * std::f32::consts::PI;
    }
    if sweep && dtheta < 0.0 {
        dtheta += 2.0 * std::f32::consts::PI;
    }

    let segments = ((dtheta.abs() / (std::f32::consts::PI / 2.0)).ceil() as usize).max(1);
    let delta = dtheta / segments as f32;
    let t = (4.0 / 3.0) * (delta / 4.0).tan();

    let mut theta = theta1;
    let (mut px, mut py) = (x0, y0);
    for i in 0..segments {
        let theta_end = theta + delta;
        let (cos1, sin1) = (theta.cos(), theta.sin());
        let (cos2, sin2) = (theta_end.cos(), theta_end.sin());
        let p1 = (cx + rx * cos1, cy + ry * sin1);
        let p2 = if i == segments - 1 { (x, y) } else { (cx + rx * cos2, cy + ry * sin2) };
        let q1 = (p1.0 - t * rx * sin1, p1.1 + t * ry * cos1);
        let q2 = (p2.0 + t * rx * sin2, p2.1 - t * ry * cos2);
        out.push([px, py, q1.0, q1.1, q2.0, q2.1, p2.0, p2.1]);
        theta = theta_end;
        px = p2.0;
        py = p2.1;
    }
}
