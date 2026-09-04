//! Restarting the machine — the real counterpart of the original's
//! `RestartIfNeeded` (`src/kp_includes/functions/functions.au3`), which
//! calls AutoIt's `Shutdown(6)` (force) falling back to `Shutdown(2)`
//! around `ExitWindowsEx`. Never call [`reboot_machine`] without explicit
//! confirmation from whoever is running the tool — this restarts the
//! whole machine, not just the app.

use windows::core::PCWSTR;
use windows::Win32::Foundation::{CloseHandle, HANDLE, LUID};
use windows::Win32::Security::{
    AdjustTokenPrivileges, LookupPrivilegeValueW, LUID_AND_ATTRIBUTES, SE_PRIVILEGE_ENABLED,
    TOKEN_ADJUST_PRIVILEGES, TOKEN_PRIVILEGES, TOKEN_QUERY,
};
use windows::Win32::System::Shutdown::{
    ExitWindowsEx, EWX_FORCEIFHUNG, EWX_REBOOT, SHTDN_REASON_FLAG_PLANNED,
    SHTDN_REASON_MAJOR_SOFTWARE, SHTDN_REASON_MINOR_MAINTENANCE,
};
use windows::Win32::System::Threading::{GetCurrentProcess, OpenProcessToken};

/// Reboots the machine right now. A normal process token — even an
/// administrator's — does not carry `SeShutdownPrivilege` by default, so
/// this enables it first via `AdjustTokenPrivileges`, then calls
/// `ExitWindowsEx(EWX_REBOOT | EWX_FORCEIFHUNG, ...)`.
pub fn reboot_machine() -> windows::core::Result<()> {
    unsafe {
        enable_shutdown_privilege()?;
        ExitWindowsEx(
            EWX_REBOOT | EWX_FORCEIFHUNG,
            SHTDN_REASON_MAJOR_SOFTWARE
                | SHTDN_REASON_MINOR_MAINTENANCE
                | SHTDN_REASON_FLAG_PLANNED,
        )
    }
}

unsafe fn enable_shutdown_privilege() -> windows::core::Result<()> {
    let mut token = HANDLE::default();
    OpenProcessToken(
        GetCurrentProcess(),
        TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY,
        &mut token,
    )?;

    let mut luid = LUID::default();
    let name: Vec<u16> = "SeShutdownPrivilege\0".encode_utf16().collect();
    let result =
        LookupPrivilegeValueW(PCWSTR::null(), PCWSTR(name.as_ptr()), &mut luid).and_then(|_| {
            let privileges = TOKEN_PRIVILEGES {
                PrivilegeCount: 1,
                Privileges: [LUID_AND_ATTRIBUTES {
                    Luid: luid,
                    Attributes: SE_PRIVILEGE_ENABLED,
                }],
            };
            AdjustTokenPrivileges(token, false, Some(&privileges), 0, None, None)
        });

    let _ = CloseHandle(token);
    result
}
