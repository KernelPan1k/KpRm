//! Native Win32/GDI+ GUI toolkit — replaces `egui`/`eframe` for `kprm`'s
//! presentation layer so the app no longer depends on an OpenGL 2.0+
//! context (which is not available on every machine this tool must run on).
//!
//! Generic and app-agnostic: knows nothing about tools, catalogs, or
//! reports. See `../../kprm/src/app.rs` for the app-specific screens built
//! on top of this crate.

#[cfg(windows)]
pub mod color;
#[cfg(windows)]
pub mod gdiplus;
#[cfg(windows)]
pub mod icons;
#[cfg(windows)]
pub mod image;
#[cfg(windows)]
pub mod scroll;
#[cfg(windows)]
pub mod window;
