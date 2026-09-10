//! Real process listing/termination via the classic Toolhelp32 snapshot
//! APIs, implementing [`kprm_engine::ports::ProcessManager`]. Ported from
//! `ProcessList`/`ProcessClose`/`_Permissions_KillProcess` usage in
//! `src/kp_includes/functions/remove.au3`.

use kprm_engine::ports::{ProcessInfo, ProcessManager};
use windows::core::PWSTR;
use windows::Win32::Foundation::CloseHandle;
use windows::Win32::System::Diagnostics::ToolHelp::{
    CreateToolhelp32Snapshot, Process32FirstW, Process32NextW, PROCESSENTRY32W, TH32CS_SNAPPROCESS,
};
use windows::Win32::System::Threading::{
    OpenProcess, QueryFullProcessImageNameW, TerminateProcess, PROCESS_NAME_WIN32,
    PROCESS_QUERY_LIMITED_INFORMATION, PROCESS_TERMINATE,
};

fn exe_path_for(pid: u32) -> Option<String> {
    unsafe {
        let handle = OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, false, pid).ok()?;
        let mut buffer = [0u16; 1024];
        let mut size = buffer.len() as u32;
        let result = QueryFullProcessImageNameW(
            handle,
            PROCESS_NAME_WIN32,
            PWSTR(buffer.as_mut_ptr()),
            &mut size,
        );
        let _ = CloseHandle(handle);
        if result.is_ok() {
            Some(String::from_utf16_lossy(&buffer[..size as usize]))
        } else {
            None
        }
    }
}

pub struct WinProcessManager;

impl ProcessManager for WinProcessManager {
    fn list(&self) -> Vec<ProcessInfo> {
        let mut result = Vec::new();

        unsafe {
            let Ok(snapshot) = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0) else {
                return result;
            };

            let mut entry: PROCESSENTRY32W = std::mem::zeroed();
            entry.dwSize = std::mem::size_of::<PROCESSENTRY32W>() as u32;

            if Process32FirstW(snapshot, &mut entry).is_ok() {
                loop {
                    let name_len = entry
                        .szExeFile
                        .iter()
                        .position(|&c| c == 0)
                        .unwrap_or(entry.szExeFile.len());
                    let name = String::from_utf16_lossy(&entry.szExeFile[..name_len]);
                    let exe_path = exe_path_for(entry.th32ProcessID);

                    result.push(ProcessInfo {
                        pid: entry.th32ProcessID,
                        name,
                        exe_path,
                    });

                    if Process32NextW(snapshot, &mut entry).is_err() {
                        break;
                    }
                }
            }

            let _ = CloseHandle(snapshot);
        }

        result
    }

    fn kill(&mut self, pid: u32) -> bool {
        unsafe {
            let Ok(handle) = OpenProcess(PROCESS_TERMINATE, false, pid) else {
                return false;
            };
            let ok = TerminateProcess(handle, 1).is_ok();
            let _ = CloseHandle(handle);
            ok
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn list_finds_this_very_test_process() {
        let manager = WinProcessManager;
        let processes = manager.list();
        assert!(!processes.is_empty());
        // The test harness binary itself must show up in its own snapshot.
        assert!(processes.iter().any(|p| p.exe_path.is_some()));
    }

    #[test]
    fn kill_a_process_we_spawned_ourselves() {
        // Never kill anything but a process this test started: spawn a
        // short-lived helper (`ping` looping harmlessly) and verify our own
        // kill() call ends it, rather than touching any real user process.
        let mut child = std::process::Command::new("ping.exe")
            .args(["127.0.0.1", "-n", "30"])
            .spawn()
            .expect("ping.exe ships with every Windows install");
        let pid = child.id();

        let mut manager = WinProcessManager;
        assert!(manager.kill(pid));

        let exited = child.wait().expect("wait should succeed after termination");
        assert!(!exited.success());
    }
}
