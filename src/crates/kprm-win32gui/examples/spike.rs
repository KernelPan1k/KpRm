//! Phase 0 spike (see the plan): confirms GDI+ links and runs under this
//! project's pinned `x86_64-pc-windows-gnu` MinGW toolchain before any real
//! toolkit code is built on top of it. Not shipped — run with
//! `cargo run -p kprm-win32gui --example spike`.
//!
//! Opens a borderless window, draws one anti-aliased rounded rect and one
//! string using an embedded TTF loaded as a GDI+ private font, exactly like
//! `kprm`'s real title bar will.

use kprm_win32gui::gdiplus::{self, argb, Font, FontFamily, Graphics, PrivateFontCollection, StringFormat};
use windows::Win32::Foundation::{HWND, LPARAM, LRESULT, WPARAM};
use windows::Win32::Graphics::Gdi::{BeginPaint, EndPaint, PAINTSTRUCT};
use windows::Win32::Graphics::GdiPlus::{FontStyleRegular, RectF, StringAlignmentNear};
use windows::Win32::UI::WindowsAndMessaging::{
    CreateWindowExW, DefWindowProcW, DispatchMessageW, GWLP_USERDATA, GetMessageW,
    GetWindowLongPtrW, LoadCursorW, MSG, PostQuitMessage, RegisterClassExW, SetWindowLongPtrW,
    ShowWindow, TranslateMessage, WM_DESTROY, WM_PAINT, WNDCLASSEXW, WNDCLASS_STYLES, WS_POPUP,
    WS_VISIBLE, SW_SHOW, CW_USEDEFAULT, IDC_ARROW,
};
use windows::Win32::System::LibraryLoader::GetModuleHandleW;
use windows::core::PCWSTR;

const BG: u32 = argb(255, 0x14, 0x16, 0x1b);
const BG_PANEL: u32 = argb(255, 0x18, 0x1b, 0x21);
const BORDER_SOFT: u32 = argb(255, 0x24, 0x27, 0x2e);
const TEXT_1: u32 = argb(255, 0xee, 0xf0, 0xf2);

/// State stashed in `GWLP_USERDATA`, retrieved and used by `WM_PAINT`.
struct SpikeState {
    _fonts: PrivateFontCollection,
    family: FontFamily,
    font: Font,
    _gdiplus: gdiplus::GdiplusToken,
}

fn wide(s: &str) -> Vec<u16> {
    s.encode_utf16().chain(std::iter::once(0)).collect()
}

unsafe extern "system" fn wndproc(hwnd: HWND, msg: u32, wparam: WPARAM, lparam: LPARAM) -> LRESULT {
    match msg {
        WM_PAINT => {
            let state_ptr = GetWindowLongPtrW(hwnd, GWLP_USERDATA) as *const SpikeState;
            if let Some(state) = state_ptr.as_ref() {
                let mut ps = PAINTSTRUCT::default();
                let hdc = BeginPaint(hwnd, &mut ps);

                let paint = || -> Result<(), gdiplus::GdiplusError> {
                    let g = Graphics::from_hdc(hdc)?;
                    g.set_smoothing_antialias()?;
                    g.set_text_rendering_cleartype()?;

                    let bg = gdiplus::SolidBrush::new(BG)?;
                    g.fill_rect(
                        RectF { X: 0.0, Y: 0.0, Width: 640.0, Height: 480.0 },
                        &bg,
                    )?;

                    let panel_rect = RectF { X: 40.0, Y: 40.0, Width: 300.0, Height: 120.0 };
                    let panel_fill = gdiplus::SolidBrush::new(BG_PANEL)?;
                    g.fill_rounded_rect(panel_rect, 8.0, &panel_fill)?;
                    let border = gdiplus::Pen::new(BORDER_SOFT, 1.0)?;
                    g.draw_rounded_rect(panel_rect, 8.0, &border)?;

                    let text_brush = gdiplus::SolidBrush::new(TEXT_1)?;
                    let format = StringFormat::new()?;
                    format.set_align(StringAlignmentNear)?;
                    g.draw_string(
                        "KpRm — GDI+ spike OK",
                        &state.font,
                        RectF { X: 56.0, Y: 80.0, Width: 268.0, Height: 40.0 },
                        &format,
                        &text_brush,
                    )?;
                    Ok(())
                };
                if let Err(e) = paint() {
                    eprintln!("spike paint error: {e:?}");
                }

                let _ = EndPaint(hwnd, &ps);
            }
            LRESULT(0)
        }
        WM_DESTROY => {
            let state_ptr = GetWindowLongPtrW(hwnd, GWLP_USERDATA) as *mut SpikeState;
            if !state_ptr.is_null() {
                drop(Box::from_raw(state_ptr));
            }
            PostQuitMessage(0);
            LRESULT(0)
        }
        _ => DefWindowProcW(hwnd, msg, wparam, lparam),
    }
}

fn main() -> windows::core::Result<()> {
    unsafe {
        let hinstance = GetModuleHandleW(None)?.into();
        let class_name = wide("KprmWin32GuiSpike");
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
        let atom = RegisterClassExW(&wc);
        assert!(atom != 0, "RegisterClassExW failed");

        let title = wide("KpRm — Win32 GDI+ spike");
        let hwnd = CreateWindowExW(
            Default::default(),
            PCWSTR(class_name.as_ptr()),
            PCWSTR(title.as_ptr()),
            WS_POPUP | WS_VISIBLE,
            CW_USEDEFAULT,
            CW_USEDEFAULT,
            640,
            480,
            None,
            None,
            hinstance,
            None,
        )?;

        let gdiplus_token = gdiplus::GdiplusToken::startup().expect("GdiplusStartup failed");
        let fonts = PrivateFontCollection::new().expect("PrivateFontCollection::new failed");
        fonts
            .add_memory_font(include_bytes!("../../kprm/assets/fonts/SpaceGrotesk.ttf"))
            .expect("add_memory_font failed");
        let family =
            FontFamily::from_name("Space Grotesk", &fonts).expect("FontFamily::from_name failed");
        let font = Font::new(&family, 16.0, FontStyleRegular).expect("Font::new failed");

        let state = Box::new(SpikeState {
            _fonts: fonts,
            family,
            font,
            _gdiplus: gdiplus_token,
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
