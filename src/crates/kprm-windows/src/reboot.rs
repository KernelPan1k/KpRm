//! Restarting the machine — the real counterpart of the original's
//! `RestartIfNeeded` (`src/kp_includes/functions/functions.au3`), which
//! calls AutoIt's `Shutdown(6)` (force) falling back to `Shutdown(2)`
//! around `ExitWindowsEx`. Never call [`reboot_machine`] without explicit
//! confirmation from whoever is running the tool — this restarts the
//! whole machine, not just the app.

use windows::Win32::Security::SE_SHUTDOWN_NAME;
use windows::Win32::System::Shutdown::{
    ExitWindowsEx, EWX_FORCEIFHUNG, EWX_REBOOT, SHTDN_REASON_FLAG_PLANNED,
    SHTDN_REASON_MAJOR_SOFTWARE, SHTDN_REASON_MINOR_MAINTENANCE,
};

use crate::privilege::enable_privilege;

/// Reboots the machine right now. A normal process token — even an
/// administrator's — does not carry `SeShutdownPrivilege` by default, so
/// this enables it first via `AdjustTokenPrivileges`, then calls
/// `ExitWindowsEx(EWX_REBOOT | EWX_FORCEIFHUNG, ...)`.
pub fn reboot_machine() -> windows::core::Result<()> {
    enable_privilege(SE_SHUTDOWN_NAME)?;
    unsafe {
        ExitWindowsEx(
            EWX_REBOOT | EWX_FORCEIFHUNG,
            SHTDN_REASON_MAJOR_SOFTWARE
                | SHTDN_REASON_MINOR_MAINTENANCE
                | SHTDN_REASON_FLAG_PLANNED,
        )
    }
}
