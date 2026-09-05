//! Single-instance guard via a named Win32 mutex — the real counterpart of
//! the original's `kprm_is_running.au3`
//! (`_WinAPI_CreateMutex("KpRm_MUTEX", True, 0)` + `GetLastError`).

use windows::core::PCWSTR;
use windows::Win32::Foundation::{GetLastError, ERROR_ALREADY_EXISTS, HWND};
use windows::Win32::System::Threading::CreateMutexW;
use windows::Win32::UI::WindowsAndMessaging::{MessageBoxW, MB_ICONINFORMATION, MB_OK};

const MUTEX_NAME: &str = "KpRm_MUTEX";

/// `true` if another instance already holds the named mutex — the caller
/// should refuse to start (matching the original's "already running"
/// message) instead of proceeding.
///
/// The mutex handle this creates/opens is deliberately never closed: it
/// has no `Drop` impl in the `windows` crate, so simply not calling
/// `CloseHandle` on it keeps it held for this process' entire lifetime,
/// exactly what a "some other instance is already running" check needs.
/// Windows releases it automatically when the process exits.
pub fn another_instance_is_running() -> bool {
    let wide: Vec<u16> = MUTEX_NAME
        .encode_utf16()
        .chain(std::iter::once(0))
        .collect();
    match unsafe { CreateMutexW(None, true, PCWSTR(wide.as_ptr())) } {
        Ok(_handle) => (unsafe { GetLastError() }) == ERROR_ALREADY_EXISTS,
        Err(_) => false,
    }
}

/// A blocking native message box with an OK button — no window/eframe
/// context needed, so it's usable before any of that exists (e.g. right
/// after [`another_instance_is_running`] returns `true`, before deciding
/// whether to even create a window).
pub fn show_message_box(title: &str, text: &str) {
    let title: Vec<u16> = title.encode_utf16().chain(std::iter::once(0)).collect();
    let text: Vec<u16> = text.encode_utf16().chain(std::iter::once(0)).collect();
    unsafe {
        MessageBoxW(
            HWND::default(),
            PCWSTR(text.as_ptr()),
            PCWSTR(title.as_ptr()),
            MB_OK | MB_ICONINFORMATION,
        );
    }
}

#[cfg(test)]
mod tests {
    use windows::Win32::Foundation::CloseHandle;

    use super::*;

    #[test]
    fn a_second_open_of_the_same_named_mutex_reports_already_exists() {
        // A name distinct from the real "KpRm_MUTEX" so this can't collide
        // with (or be confused by) an actual kprm.exe running on this
        // machine — tests the same underlying mechanism
        // `another_instance_is_running` relies on, without touching the
        // production constant.
        let name: Vec<u16> = "KpRmRustTests_SingleInstanceMutex\0"
            .encode_utf16()
            .collect();

        let first = unsafe { CreateMutexW(None, true, PCWSTR(name.as_ptr())) }.unwrap();
        let second = unsafe { CreateMutexW(None, true, PCWSTR(name.as_ptr())) }.unwrap();
        assert_eq!(unsafe { GetLastError() }, ERROR_ALREADY_EXISTS);

        unsafe {
            let _ = CloseHandle(second);
            let _ = CloseHandle(first);
        }
    }
}
