//! Real adapter for [`kprm_engine::ports::SystemRestore`]: removes a single
//! System Restore point via `SRRemoveRestorePoint` (`srclient.dll`), the
//! Windows API meant for exactly this — see
//! [`kprm_engine::restore_point::remove_all_restore_points`] for why this
//! replaced both `vssadmin delete shadows` and cycling
//! `Disable`/`Enable-ComputerRestore`.

use kprm_engine::ports::SystemRestore;
use windows::Win32::System::Restore::SRRemoveRestorePoint;

pub struct WinSystemRestore;

impl SystemRestore for WinSystemRestore {
    fn remove_point(&mut self, sequence_number: u32) -> bool {
        // SAFETY: SRRemoveRestorePoint takes a plain sequence number and
        // returns a status code; no pointers, no preconditions beyond the
        // DLL being loadable (present on every consumer/Pro/Enterprise
        // SKU shipping System Restore).
        unsafe { SRRemoveRestorePoint(sequence_number) == 0 }
    }
}
