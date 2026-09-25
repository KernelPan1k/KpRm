//! Window class registration, message loop, and double buffering for a
//! single borderless, entirely owner-drawn `WS_POPUP` window — see the
//! plan's "Architecture" section: one HWND, no native child controls,
//! layout recomputed procedurally on every paint.

use crate::gdiplus::{GdiplusToken, Graphics};
use core::ffi::c_void;
use windows::Win32::Foundation::{HWND, LPARAM, LRESULT, POINT, RECT, WPARAM};
use windows::Win32::Graphics::Dwm::{
    DwmExtendFrameIntoClientArea, DwmSetWindowAttribute, DWMWA_WINDOW_CORNER_PREFERENCE,
    DWMWCP_ROUND,
};
use windows::Win32::Graphics::Gdi::{
    BeginPaint, BitBlt, CreateCompatibleBitmap, CreateCompatibleDC, DeleteDC, DeleteObject,
    EndPaint, InvalidateRect, ScreenToClient, SelectObject, HBITMAP, HDC, PAINTSTRUCT, SRCCOPY,
};
use windows::Win32::UI::Controls::MARGINS;
use windows::Win32::UI::HiDpi::{
    GetDpiForWindow, SetProcessDpiAwarenessContext, DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2,
};
use windows::Win32::UI::WindowsAndMessaging::{
    CreateWindowExW, DefWindowProcW, DestroyWindow, DispatchMessageW, GetClientRect, GetMessageW,
    GetWindowLongPtrW, LoadCursorW, PostQuitMessage, RegisterClassExW, SetWindowLongPtrW,
    ShowWindow, TranslateMessage, CW_USEDEFAULT, GWLP_USERDATA, HTCAPTION, HTCLIENT, IDC_ARROW,
    MINMAXINFO, MSG, SetWindowPos, SW_MINIMIZE, SW_SHOW, SWP_NOMOVE, SWP_NOZORDER, WM_APP, WM_CLOSE,
    WM_DESTROY, WM_DPICHANGED, WM_GETMINMAXINFO, WM_LBUTTONDOWN, WM_LBUTTONUP, WM_MOUSEMOVE,
    WM_MOUSEWHEEL, WM_NCHITTEST, WM_PAINT, WM_SIZE, WNDCLASSEXW, WNDCLASS_STYLES, WS_EX_APPWINDOW,
    WS_POPUP,
};
use windows::Win32::System::LibraryLoader::GetModuleHandleW;
use windows::core::PCWSTR;

pub struct WindowConfig {
    pub title: String,
    pub size: (i32, i32),
    pub min_size: (i32, i32),
}

/// What a point (in logical, DPI-scaled client pixels) hit-tests as, for
/// `WM_NCHITTEST` purposes. Button clicks (minimize/close) are *not*
/// reported here — those are hand-painted content inside the client area
/// and go through the ordinary mouse callbacks below, exactly like every
/// other widget.
pub enum HitZone {
    Client,
    Caption,
}

/// Implemented by the app-specific screen logic (`kprm`'s `app.rs`).
/// Coordinates passed to every callback are logical pixels (already
/// divided by the current DPI scale) with the origin at the client area's
/// top-left, matching the coordinate space `paint` draws into.
pub trait AppWindow {
    fn paint(&mut self, g: &Graphics, width: f32, height: f32);
    /// `width`/`height` are the same current logical client size `paint`
    /// was last called with — needed since the drag region (everything in
    /// the title bar except the button rects) depends on where those
    /// buttons currently sit, which shifts with window width.
    fn hit_zone(&self, x: f32, y: f32, width: f32, height: f32) -> HitZone;
    fn on_mouse_move(&mut self, x: f32, y: f32, width: f32, height: f32) -> bool;
    fn on_mouse_down(&mut self, x: f32, y: f32, width: f32, height: f32) -> bool;
    fn on_mouse_up(&mut self, x: f32, y: f32, width: f32, height: f32) -> bool;

    /// `notches` is the wheel delta in units of one "notch" (Windows'
    /// `WHEEL_DELTA` of 120 already divided out) — positive means the
    /// wheel moved away from the user (scroll up/content moves down).
    /// Default no-op so apps/screens with nothing scrollable don't need to
    /// implement this.
    fn on_mouse_wheel(&mut self, _x: f32, _y: f32, _notches: f32, _width: f32, _height: f32) -> bool {
        false
    }

    /// Polled after every mouse-up — the hand-painted title bar's
    /// minimize/close buttons (`kprm`'s `icon_button`) set these rather
    /// than reaching for an `HWND` themselves, mirroring how the current
    /// `egui` app requests `ViewportCommand::Minimized`/`Close` from inside
    /// its own widget code.
    fn should_close(&mut self) -> bool {
        false
    }
    fn should_minimize(&mut self) -> bool {
        false
    }
}

struct DoubleBuffer {
    memdc: HDC,
    bitmap: HBITMAP,
    width: i32,
    height: i32,
}

impl DoubleBuffer {
    fn new(screen_dc: HDC, width: i32, height: i32) -> Self {
        unsafe {
            let memdc = CreateCompatibleDC(screen_dc);
            let bitmap = CreateCompatibleBitmap(screen_dc, width.max(1), height.max(1));
            SelectObject(memdc, bitmap);
            Self { memdc, bitmap, width, height }
        }
    }
}

impl Drop for DoubleBuffer {
    fn drop(&mut self) {
        unsafe {
            let _ = DeleteObject(self.bitmap);
            let _ = DeleteDC(self.memdc);
        }
    }
}

struct WindowState {
    app: Box<dyn AppWindow>,
    buffer: Option<DoubleBuffer>,
    dpi_scale: f32,
    min_size: (i32, i32),
    _gdiplus: GdiplusToken,
}

fn wide(s: &str) -> Vec<u16> {
    s.encode_utf16().chain(std::iter::once(0)).collect()
}

fn loword_i32(lparam: LPARAM) -> i32 {
    ((lparam.0 & 0xFFFF) as i16) as i32
}

fn hiword_i32(lparam: LPARAM) -> i32 {
    (((lparam.0 >> 16) & 0xFFFF) as i16) as i32
}

unsafe fn state_of<'a>(hwnd: HWND) -> Option<&'a mut WindowState> {
    let ptr = GetWindowLongPtrW(hwnd, GWLP_USERDATA) as *mut WindowState;
    ptr.as_mut()
}

unsafe fn logical_client_size(hwnd: HWND, dpi_scale: f32) -> (f32, f32) {
    let mut rect = RECT::default();
    let _ = GetClientRect(hwnd, &mut rect);
    (
        (rect.right - rect.left) as f32 / dpi_scale,
        (rect.bottom - rect.top) as f32 / dpi_scale,
    )
}

unsafe extern "system" fn wndproc(hwnd: HWND, msg: u32, wparam: WPARAM, lparam: LPARAM) -> LRESULT {
    match msg {
        WM_NCHITTEST => {
            if let Some(state) = state_of(hwnd) {
                // WM_NCHITTEST's lParam carries *screen* coordinates in
                // both halves (not sign-extended the way client-area
                // mouse messages are) — decode as unsigned 16-bit fields.
                let mut pt = POINT {
                    x: (lparam.0 & 0xFFFF) as i32,
                    y: ((lparam.0 >> 16) & 0xFFFF) as i32,
                };
                let _ = ScreenToClient(hwnd, &mut pt);
                let x = pt.x as f32 / state.dpi_scale;
                let y = pt.y as f32 / state.dpi_scale;
                let (width, height) = logical_client_size(hwnd, state.dpi_scale);
                return match state.app.hit_zone(x, y, width, height) {
                    HitZone::Caption => LRESULT(HTCAPTION as isize),
                    HitZone::Client => LRESULT(HTCLIENT as isize),
                };
            }
            DefWindowProcW(hwnd, msg, wparam, lparam)
        }
        WM_MOUSEMOVE => {
            if let Some(state) = state_of(hwnd) {
                let x = loword_i32(lparam) as f32 / state.dpi_scale;
                let y = hiword_i32(lparam) as f32 / state.dpi_scale;
                let (width, height) = logical_client_size(hwnd, state.dpi_scale);
                if state.app.on_mouse_move(x, y, width, height) {
                    let _ = InvalidateRect(hwnd, None, false);
                }
            }
            LRESULT(0)
        }
        WM_LBUTTONDOWN => {
            if let Some(state) = state_of(hwnd) {
                let x = loword_i32(lparam) as f32 / state.dpi_scale;
                let y = hiword_i32(lparam) as f32 / state.dpi_scale;
                let (width, height) = logical_client_size(hwnd, state.dpi_scale);
                if state.app.on_mouse_down(x, y, width, height) {
                    let _ = InvalidateRect(hwnd, None, false);
                }
            }
            LRESULT(0)
        }
        WM_LBUTTONUP => {
            if let Some(state) = state_of(hwnd) {
                let x = loword_i32(lparam) as f32 / state.dpi_scale;
                let y = hiword_i32(lparam) as f32 / state.dpi_scale;
                let (width, height) = logical_client_size(hwnd, state.dpi_scale);
                if state.app.on_mouse_up(x, y, width, height) {
                    let _ = InvalidateRect(hwnd, None, false);
                }
                if state.app.should_close() {
                    let _ = DestroyWindow(hwnd);
                } else if state.app.should_minimize() {
                    let _ = ShowWindow(hwnd, SW_MINIMIZE);
                }
            }
            LRESULT(0)
        }
        WM_MOUSEWHEEL => {
            if let Some(state) = state_of(hwnd) {
                // Unlike every other mouse message, WM_MOUSEWHEEL's lParam
                // is in *screen* coordinates.
                let mut pt = POINT { x: (lparam.0 & 0xFFFF) as i32, y: ((lparam.0 >> 16) & 0xFFFF) as i32 };
                let _ = ScreenToClient(hwnd, &mut pt);
                let x = pt.x as f32 / state.dpi_scale;
                let y = pt.y as f32 / state.dpi_scale;
                // wParam's high word is the signed delta, a multiple of
                // WHEEL_DELTA (120); wParam itself is conceptually 32-bit.
                let raw = wparam.0 as u32;
                let notches = (((raw >> 16) as i16) as f32) / 120.0;
                let (width, height) = logical_client_size(hwnd, state.dpi_scale);
                if state.app.on_mouse_wheel(x, y, notches, width, height) {
                    let _ = InvalidateRect(hwnd, None, false);
                }
            }
            LRESULT(0)
        }
        WM_SIZE => {
            if let Some(state) = state_of(hwnd) {
                state.buffer = None; // recreated lazily on the next WM_PAINT
            }
            let _ = InvalidateRect(hwnd, None, false);
            LRESULT(0)
        }
        WM_GETMINMAXINFO => {
            if let Some(state) = state_of(hwnd) {
                let info = &mut *(lparam.0 as *mut MINMAXINFO);
                info.ptMinTrackSize.x = (state.min_size.0 as f32 * state.dpi_scale) as i32;
                info.ptMinTrackSize.y = (state.min_size.1 as f32 * state.dpi_scale) as i32;
            }
            LRESULT(0)
        }
        WM_DPICHANGED => {
            if let Some(state) = state_of(hwnd) {
                state.dpi_scale = (wparam.0 & 0xFFFF) as f32 / 96.0;
                let suggested = &*(lparam.0 as *const RECT);
                let _ = SetWindowPos(
                    hwnd,
                    None,
                    suggested.left,
                    suggested.top,
                    suggested.right - suggested.left,
                    suggested.bottom - suggested.top,
                    SWP_NOZORDER,
                );
            }
            LRESULT(0)
        }
        WM_PAINT => {
            if let Some(state) = state_of(hwnd) {
                let mut client = RECT::default();
                let _ = GetClientRect(hwnd, &mut client);
                let (w, h) = (client.right - client.left, client.bottom - client.top);

                let mut ps = PAINTSTRUCT::default();
                let screen_dc = BeginPaint(hwnd, &mut ps);

                let needs_new_buffer = match &state.buffer {
                    Some(b) => b.width != w || b.height != h,
                    None => true,
                };
                if needs_new_buffer {
                    state.buffer = Some(DoubleBuffer::new(screen_dc, w, h));
                }

                if let Some(buffer) = &state.buffer {
                    if let Ok(g) = Graphics::from_hdc(buffer.memdc) {
                        let _ = g.set_smoothing_antialias();
                        let _ = g.set_text_rendering_cleartype();
                        // `w`/`h` (and everything GetClientRect/mouse
                        // messages report) are physical pixels; the app
                        // itself works entirely in logical (96-DPI) pixels,
                        // so the Graphics gets a matching world-transform
                        // scale rather than the app rescaling every value.
                        let _ = g.set_scale(state.dpi_scale);
                        state
                            .app
                            .paint(&g, w as f32 / state.dpi_scale, h as f32 / state.dpi_scale);
                    }
                    let _ = BitBlt(screen_dc, 0, 0, w, h, buffer.memdc, 0, 0, SRCCOPY);
                }

                let _ = EndPaint(hwnd, &ps);
            }
            LRESULT(0)
        }
        WM_CLOSE => {
            let _ = DestroyWindow(hwnd);
            LRESULT(0)
        }
        WM_DESTROY => {
            let ptr = GetWindowLongPtrW(hwnd, GWLP_USERDATA) as *mut WindowState;
            if !ptr.is_null() {
                drop(Box::from_raw(ptr));
            }
            PostQuitMessage(0);
            LRESULT(0)
        }
        // Any app-defined `WM_APP + n` message (e.g. `kprm`'s worker
        // wake-up notification) means "something changed, repaint" — the
        // toolkit doesn't need to know which one specifically, so this one
        // generic case covers every app's custom messages.
        msg if msg >= WM_APP => {
            let _ = InvalidateRect(hwnd, None, false);
            LRESULT(0)
        }
        _ => DefWindowProcW(hwnd, msg, wparam, lparam),
    }
}

/// Registers the window class, creates the borderless popup window (rounded
/// corners on Windows 11 via DWM, a native DWM drop shadow on both Windows
/// 10 and 11), and runs the message loop until the window is destroyed.
///
/// `build_app` is called only *after* `GdiplusStartup` and after the window
/// itself exists — any embedded fonts/images the app loads at construction
/// time need GDI+ already running, and an app that owns a background
/// thread (like `kprm`'s worker) needs the real `HWND` to post wake-up
/// notifications to — so the app can't be built by the caller before
/// calling `run`.
pub fn run<A: AppWindow + 'static>(
    cfg: WindowConfig,
    build_app: impl FnOnce(HWND) -> A,
) -> windows::core::Result<()> {
    unsafe {
        // Declarative DPI awareness (the manifest's `dpiAwareness` element)
        // is the real, shipped mechanism (see BUILDING.md) — this call is
        // just so `kprm-win32gui`'s own examples behave correctly without
        // needing a manifest of their own. Harmless if the manifest already
        // set it (returns an error, which we ignore).
        let _ = SetProcessDpiAwarenessContext(DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2);

        let gdiplus = GdiplusToken::startup().expect("GdiplusStartup failed");

        let hinstance = GetModuleHandleW(None)?.into();
        let class_name = wide("KprmWin32GuiWindow");
        let cursor = LoadCursorW(None, IDC_ARROW)?;

        let wc = WNDCLASSEXW {
            cbSize: std::mem::size_of::<WNDCLASSEXW>() as u32,
            style: WNDCLASS_STYLES(0),
            lpfnWndProc: Some(wndproc),
            hInstance: hinstance,
            hCursor: cursor,
            lpszClassName: PCWSTR(class_name.as_ptr()),
            ..Default::default()
        };
        // Registering the same class name twice (e.g. a second `run()` in
        // the same process, as tests might do) is expected to fail here —
        // ignore the failure, the class already being registered is fine.
        let _ = RegisterClassExW(&wc);

        let title = wide(&cfg.title);
        // Not WS_VISIBLE yet: `cfg.size` is in logical (96-DPI) pixels, the
        // same unit the app's layout works in, but `CreateWindowExW`'s
        // width/height are always physical pixels regardless of the
        // process's DPI awareness — on a scaled display this would create
        // a window that's physically correct-looking-at-96-DPI but far too
        // small on screen. The fix (immediately below) is the standard
        // "create small, correct once the real DPI is known" pattern:
        // resize before ever showing the window, so there's no visible
        // jump.
        let hwnd = CreateWindowExW(
            WS_EX_APPWINDOW,
            PCWSTR(class_name.as_ptr()),
            PCWSTR(title.as_ptr()),
            WS_POPUP,
            CW_USEDEFAULT,
            CW_USEDEFAULT,
            cfg.size.0,
            cfg.size.1,
            None,
            None,
            hinstance,
            None,
        )?;

        let initial_dpi_scale = GetDpiForWindow(hwnd) as f32 / 96.0;
        if (initial_dpi_scale - 1.0).abs() > f32::EPSILON {
            let _ = SetWindowPos(
                hwnd,
                None,
                0,
                0,
                (cfg.size.0 as f32 * initial_dpi_scale) as i32,
                (cfg.size.1 as f32 * initial_dpi_scale) as i32,
                SWP_NOMOVE | SWP_NOZORDER,
            );
        }

        // Best-effort visual chrome: rounded corners require Windows 11
        // (DWMWA_WINDOW_CORNER_PREFERENCE is silently a no-op/error on
        // Windows 10, which then keeps square corners) — the drop shadow
        // via the classic 1px frame-extension trick works on both.
        let corner_pref = DWMWCP_ROUND;
        let _ = DwmSetWindowAttribute(
            hwnd,
            DWMWA_WINDOW_CORNER_PREFERENCE,
            &corner_pref as *const _ as *const c_void,
            std::mem::size_of_val(&corner_pref) as u32,
        );
        let shadow_margins = MARGINS {
            cxLeftWidth: 1,
            cxRightWidth: 1,
            cyTopHeight: 1,
            cyBottomHeight: 1,
        };
        let _ = DwmExtendFrameIntoClientArea(hwnd, &shadow_margins);

        // Built only now (not before `CreateWindowExW`): an app that talks
        // to a background thread (like `kprm`'s worker) needs its own
        // `HWND` to post wake-up notifications to.
        let app = build_app(hwnd);

        let dpi = GetDpiForWindow(hwnd);
        let state = Box::new(WindowState {
            app: Box::new(app),
            buffer: None,
            dpi_scale: dpi as f32 / 96.0,
            min_size: cfg.min_size,
            _gdiplus: gdiplus,
        });
        SetWindowLongPtrW(hwnd, GWLP_USERDATA, Box::into_raw(state) as isize);

        let _ = ShowWindow(hwnd, SW_SHOW);

        let mut msg = MSG::default();
        while GetMessageW(&mut msg, None, 0, 0).as_bool() {
            let _ = TranslateMessage(&msg);
            DispatchMessageW(&msg);
        }
    }
    Ok(())
}
