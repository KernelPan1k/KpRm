//! Checking whether this process is running elevated. `kprm-gui` sidesteps
//! this entirely by requesting `requireAdministrator` in its exe manifest
//! (`assets/app.manifest`) — Windows elevates it via UAC before a single
//! line of the app runs. `kprm-cli` has no such manifest (forcing UAC on
//! every invocation, including harmless read-only ones like `catalog
//! stats`, would be worse than the original's always-elevated behavior),
//! so it checks at runtime instead and refuses the destructive path if
//! not elevated, rather than silently failing every privileged operation
//! one by one.

use windows::Win32::Foundation::{CloseHandle, HANDLE};
use windows::Win32::Security::{GetTokenInformation, TokenElevation, TOKEN_ELEVATION, TOKEN_QUERY};
use windows::Win32::System::Threading::{GetCurrentProcess, OpenProcessToken};

/// `true` if this process holds an elevated (admin) token.
pub fn is_elevated() -> bool {
    unsafe {
        let mut token = HANDLE::default();
        if OpenProcessToken(GetCurrentProcess(), TOKEN_QUERY, &mut token).is_err() {
            return false;
        }

        let mut elevation = TOKEN_ELEVATION::default();
        let mut returned_len = 0u32;
        let ok = GetTokenInformation(
            token,
            TokenElevation,
            Some(&mut elevation as *mut _ as *mut core::ffi::c_void),
            std::mem::size_of::<TOKEN_ELEVATION>() as u32,
            &mut returned_len,
        )
        .is_ok();

        let _ = CloseHandle(token);
        ok && elevation.TokenIsElevated != 0
    }
}
