//! PNG loading via GDI+'s own image codec (fed an in-memory `IStream`, no
//! file I/O) plus the pixel-level "recolor to white" pass `kprm`'s current
//! `egui` code applies to `bug.png` so the logo silhouette reads clearly on
//! the dark title bar.

use crate::gdiplus::{check, GdiplusError, Graphics};
use windows::Win32::Graphics::GdiPlus as gp;
use windows::Win32::UI::Shell::SHCreateMemStream;

/// GDI+'s `PixelFormat32bppARGB` — not exported by `windows-rs` (it's a
/// preprocessor macro in `gdipluspixelformats.h`, not a DLL symbol), so
/// it's hardcoded here; the value is a stable, documented Win32 constant
/// unchanged since GDI+ 1.0.
const PIXEL_FORMAT_32BPP_ARGB: i32 = 0x0026_200A;

pub struct Bitmap {
    ptr: *mut gp::GpBitmap,
    pub width: u32,
    pub height: u32,
}

impl Bitmap {
    pub fn from_png_bytes(bytes: &'static [u8]) -> Result<Self, GdiplusError> {
        unsafe {
            let stream = SHCreateMemStream(Some(bytes)).ok_or(GdiplusError(-1))?;
            let mut bitmap = std::ptr::null_mut();
            check(gp::GdipCreateBitmapFromStream(&stream, &mut bitmap))?;
            let mut width = 0u32;
            let mut height = 0u32;
            check(gp::GdipGetImageWidth(bitmap as *mut gp::GpImage, &mut width))?;
            check(gp::GdipGetImageHeight(bitmap as *mut gp::GpImage, &mut height))?;
            Ok(Self { ptr: bitmap, width, height })
        }
    }

    /// Forces every pixel's RGB to pure white, alpha untouched — the same
    /// recolor `kprm`'s current egui code applies to the bug logo so a
    /// dark silhouette PNG shows up against the dark title bar regardless
    /// of its original color.
    pub fn recolor_white(&self) -> Result<(), GdiplusError> {
        unsafe {
            let rect = gp::Rect { X: 0, Y: 0, Width: self.width as i32, Height: self.height as i32 };
            let mut data = gp::BitmapData::default();
            check(gp::GdipBitmapLockBits(
                self.ptr,
                &rect,
                (gp::ImageLockModeRead.0 | gp::ImageLockModeWrite.0) as u32,
                PIXEL_FORMAT_32BPP_ARGB,
                &mut data,
            ))?;
            // 32bppARGB's in-memory byte order is B, G, R, A.
            let base = data.Scan0 as *mut u8;
            for y in 0..self.height as isize {
                let row = base.offset(y * data.Stride as isize);
                for x in 0..self.width as isize {
                    let px = row.offset(x * 4);
                    *px = 255;
                    *px.offset(1) = 255;
                    *px.offset(2) = 255;
                }
            }
            check(gp::GdipBitmapUnlockBits(self.ptr, &mut data))
        }
    }

    pub fn draw(&self, g: &Graphics, dest: gp::RectF) -> Result<(), GdiplusError> {
        unsafe {
            check(gp::GdipDrawImageRect(
                g.as_raw(),
                self.ptr as *mut gp::GpImage,
                dest.X,
                dest.Y,
                dest.Width,
                dest.Height,
            ))
        }
    }
}

impl Drop for Bitmap {
    fn drop(&mut self) {
        unsafe {
            let _ = gp::GdipDisposeImage(self.ptr as *mut gp::GpImage);
        }
    }
}
