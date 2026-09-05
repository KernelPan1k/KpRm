//! Enabling a privilege (e.g. `SeShutdownPrivilege`, `SeBackupPrivilege`)
//! on this process' own token. A normal token — even an administrator's —
//! doesn't hold most privileges enabled by default; `AdjustTokenPrivileges`
//! turns one on for the lifetime of the process. Shared by [`crate::reboot`]
//! and [`crate::registry`] (registry hive backup needs `SeBackupPrivilege`
//! to read protected subtrees of `HKLM\SOFTWARE`).

use windows::core::PCWSTR;
use windows::Win32::Foundation::{CloseHandle, HANDLE, LUID};
use windows::Win32::Security::{
    AdjustTokenPrivileges, LookupPrivilegeValueW, LUID_AND_ATTRIBUTES, SE_PRIVILEGE_ENABLED,
    TOKEN_ADJUST_PRIVILEGES, TOKEN_PRIVILEGES, TOKEN_QUERY,
};
use windows::Win32::System::Threading::{GetCurrentProcess, OpenProcessToken};

pub fn enable_privilege(name: PCWSTR) -> windows::core::Result<()> {
    unsafe {
        let mut token = HANDLE::default();
        OpenProcessToken(
            GetCurrentProcess(),
            TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY,
            &mut token,
        )?;

        let mut luid = LUID::default();
        let result = LookupPrivilegeValueW(PCWSTR::null(), name, &mut luid).and_then(|_| {
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
}
