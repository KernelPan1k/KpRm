//! Post-disinfection maintenance actions: temp-file cleanup, DNS flush,
//! firewall reset, recycle bin, SFC, and DISM. All implemented against
//! the [`crate::ports`] abstractions so they are testable without Windows.

use crate::paths::KnownDirs;
use crate::ports::{CommandRunner, FileSystem, Registry, Removal};
use kprm_catalog::EntryKind;

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct MaintenanceResult {
    pub description: String,
    pub succeeded: bool,
}

impl MaintenanceResult {
    fn ok(description: impl Into<String>) -> Self {
        Self {
            description: description.into(),
            succeeded: true,
        }
    }
    fn fail(description: impl Into<String>) -> Self {
        Self {
            description: description.into(),
            succeeded: false,
        }
    }
}

/// `ipconfig /flushdns` — clears the local DNS resolution cache.
pub fn flush_dns(commands: &mut dyn CommandRunner) -> MaintenanceResult {
    if commands.run("ipconfig.exe", &["/flushdns"]) {
        MaintenanceResult::ok("ipconfig /flushdns")
    } else {
        MaintenanceResult::fail("ipconfig /flushdns")
    }
}

/// `netsh advfirewall reset` — resets Windows Firewall to its defaults.
pub fn reset_firewall(commands: &mut dyn CommandRunner) -> MaintenanceResult {
    let (succeeded, output) =
        commands.run_with_output("netsh.exe", &["advfirewall", "reset"]);
    let description = if succeeded {
        "netsh advfirewall reset".to_string()
    } else {
        let flat: String = output.split_whitespace().collect::<Vec<_>>().join(" ");
        if flat.is_empty() {
            "netsh advfirewall reset".to_string()
        } else {
            let snippet: String = flat.chars().take(200).collect();
            format!("netsh advfirewall reset : {snippet}")
        }
    };
    MaintenanceResult { description, succeeded }
}

/// `sfc /scannow` — verifies and repairs protected Windows system files.
/// Requires elevation and may take several minutes.
pub fn run_sfc(commands: &mut dyn CommandRunner) -> MaintenanceResult {
    if commands.run("sfc.exe", &["/scannow"]) {
        MaintenanceResult::ok("sfc /scannow")
    } else {
        MaintenanceResult::fail("sfc /scannow")
    }
}

/// `DISM /Online /Cleanup-Image /RestoreHealth` — repairs the Windows
/// component store from Windows Update. Requires Internet; may take
/// 20–30 minutes.
pub fn run_dism(commands: &mut dyn CommandRunner) -> MaintenanceResult {
    if commands.run(
        "DISM.exe",
        &["/Online", "/Cleanup-Image", "/RestoreHealth"],
    ) {
        MaintenanceResult::ok("DISM /Online /Cleanup-Image /RestoreHealth")
    } else {
        MaintenanceResult::fail("DISM /Online /Cleanup-Image /RestoreHealth")
    }
}

/// Empties the current user's Recycle Bin via PowerShell.
/// `Clear-RecycleBin` is available on PowerShell 5.1+ (Windows 10+).
pub fn empty_recycle_bin(commands: &mut dyn CommandRunner) -> MaintenanceResult {
    if commands.run(
        "powershell.exe",
        &[
            "-NoProfile",
            "-NonInteractive",
            "-Command",
            "Clear-RecycleBin -Force -ErrorAction SilentlyContinue",
        ],
    ) {
        MaintenanceResult::ok("Clear-RecycleBin")
    } else {
        MaintenanceResult::fail("Clear-RecycleBin")
    }
}

/// `netsh winsock reset` — resets the Winsock catalog corrupted by network
/// malware (rootkits, LSP hijackers). Requires a reboot to take effect.
pub fn reset_winsock(commands: &mut dyn CommandRunner) -> MaintenanceResult {
    let (succeeded, output) = commands.run_with_output("netsh.exe", &["winsock", "reset"]);
    let description = if succeeded {
        "netsh winsock reset".to_string()
    } else {
        let flat: String = output.split_whitespace().collect::<Vec<_>>().join(" ");
        if flat.is_empty() {
            "netsh winsock reset".to_string()
        } else {
            format!("netsh winsock reset : {}", flat.chars().take(200).collect::<String>())
        }
    };
    MaintenanceResult { description, succeeded }
}

/// Rewrites the Windows hosts file with only the two standard localhost
/// entries, removing any malware-added redirects (antivirus blocks, etc.).
pub fn reset_hosts_file(commands: &mut dyn CommandRunner, dirs: &dyn KnownDirs) -> MaintenanceResult {
    let hosts = format!("{}\\System32\\drivers\\etc\\hosts", dirs.windows_dir());
    let cmd = format!(
        "Set-Content -Path '{}' -Value @('127.0.0.1 localhost','::1 localhost') -Encoding ASCII -Force",
        hosts
    );
    if commands.run("powershell.exe", &["-NoProfile", "-NonInteractive", "-Command", &cmd]) {
        MaintenanceResult::ok(format!("Hosts file reset: {hosts}"))
    } else {
        MaintenanceResult::fail(format!("Failed to reset the hosts file: {hosts}"))
    }
}

/// Disables the proxy in HKCU Internet Settings (ProxyEnable/ProxyServer/
/// AutoConfigURL) and resets the system-wide WinHTTP proxy stack
/// (`netsh winhttp reset proxy`). Covers IE, Edge Legacy, and any app
/// that reads WinHTTP — the two most common malware proxy vectors.
pub fn remove_proxy(registry: &mut dyn Registry, commands: &mut dyn CommandRunner) -> MaintenanceResult {
    let key = r"HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings";
    registry.write_dword(key, "ProxyEnable", 0);
    commands.run(
        "powershell.exe",
        &[
            "-NoProfile",
            "-NonInteractive",
            "-Command",
            r"$k='HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings'; 'ProxyServer','ProxyOverride','AutoConfigURL'|%{Remove-ItemProperty $k -Name $_ -EA SilentlyContinue}",
        ],
    );
    commands.run("netsh.exe", &["winhttp", "reset", "proxy"]);
    MaintenanceResult::ok("Internet Options + WinHTTP proxy removed")
}

/// Deletes the Group Policy registry subtrees that adware uses to lock Chrome,
/// Edge, and Firefox settings (home page, extension whitelist, search engine…).
/// Removes both the HKLM (machine-wide) and HKCU (per-user) policy keys.
pub fn reset_browser_policies(registry: &mut dyn Registry) -> MaintenanceResult {
    let keys = [
        r"HKLM\SOFTWARE\Policies\Google\Chrome",
        r"HKLM\SOFTWARE\Policies\Google\Update",
        r"HKLM\SOFTWARE\Policies\Microsoft\Edge",
        r"HKLM\SOFTWARE\Policies\Mozilla\Firefox",
        r"HKCU\SOFTWARE\Policies\Google\Chrome",
        r"HKCU\SOFTWARE\Policies\Microsoft\Edge",
        r"HKCU\SOFTWARE\Policies\Mozilla\Firefox",
    ];
    let removed: usize = keys.iter().filter(|k| registry.delete_key(k)).count();
    MaintenanceResult::ok(format!("{removed} browser policy key(s) removed"))
}

/// Restores the default HKCR shell associations for `.exe`, `.bat`, `.com`,
/// and `.lnk`, then clears any per-user `UserChoice` overrides in HKCU that
/// would shadow them. Uses `reg.exe` to write the string values that the
/// [`Registry`] port does not currently expose.
pub fn restore_file_associations(commands: &mut dyn CommandRunner) -> MaintenanceResult {
    let ops: &[(&str, &[&str])] = &[
        ("reg.exe", &["add", r"HKCR\.exe", "/ve", "/t", "REG_SZ", "/d", "exefile", "/f"]),
        ("reg.exe", &["add", r"HKCR\exefile\shell\open\command", "/ve", "/t", "REG_SZ", "/d", r#""%1" %*"#, "/f"]),
        ("reg.exe", &["add", r"HKCR\.bat", "/ve", "/t", "REG_SZ", "/d", "batfile", "/f"]),
        ("reg.exe", &["add", r"HKCR\batfile\shell\open\command", "/ve", "/t", "REG_SZ", "/d", r#""%1" %*"#, "/f"]),
        ("reg.exe", &["add", r"HKCR\.com", "/ve", "/t", "REG_SZ", "/d", "comfile", "/f"]),
        ("reg.exe", &["add", r"HKCR\comfile\shell\open\command", "/ve", "/t", "REG_SZ", "/d", r#""%1" %*"#, "/f"]),
        ("reg.exe", &["add", r"HKCR\.lnk", "/ve", "/t", "REG_SZ", "/d", "lnkfile", "/f"]),
        ("reg.exe", &["delete", r"HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.exe\UserChoice", "/f"]),
        ("reg.exe", &["delete", r"HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.bat\UserChoice", "/f"]),
        ("reg.exe", &["delete", r"HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.com\UserChoice", "/f"]),
        ("reg.exe", &["delete", r"HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.lnk\UserChoice", "/f"]),
    ];
    for (prog, args) in ops {
        commands.run(prog, args);
    }
    MaintenanceResult::ok("Associations for .exe / .bat / .com / .lnk restored")
}

/// Deletes the direct contents of `%TEMP%` and `%WINDIR%\Temp`.
/// Locked files (in use by running processes) are skipped silently.
pub fn clean_temp_dirs(fs: &mut dyn FileSystem, dirs: &dyn KnownDirs) -> MaintenanceResult {
    let roots = [
        dirs.temp_dir().to_string(),
        format!("{}\\Temp", dirs.windows_dir()),
    ];

    let mut removed = 0usize;

    for root in &roots {
        for child in fs.list_dir(root, 1) {
            let result = match fs.kind(&child) {
                Some(EntryKind::File) => fs.remove_file(&child),
                Some(EntryKind::Folder) => fs.remove_dir(&child),
                None => continue,
            };
            if result != Removal::NotFound {
                removed += 1;
            }
        }
    }

    MaintenanceResult::ok(format!(
        "{removed} item(s) deleted from temp folders"
    ))
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::fakes::{FakeCommandRunner, FakeFileSystem, FakeRegistry};

    struct FakeDirs;
    impl KnownDirs for FakeDirs {
        fn app_data_common(&self) -> &str { r"C:\ProgramData" }
        fn desktop(&self) -> &str { r"C:\Users\bob\Desktop" }
        fn local_app_data(&self) -> &str { r"C:\Users\bob\AppData\Local" }
        fn home_drive(&self) -> &str { "C:" }
        fn temp_dir(&self) -> &str { r"C:\Users\bob\AppData\Local\Temp" }
        fn user_profile(&self) -> &str { r"C:\Users\bob" }
        fn app_data(&self) -> &str { r"C:\Users\bob\AppData\Roaming" }
        fn desktop_common(&self) -> &str { r"C:\Users\Public\Desktop" }
        fn windows_dir(&self) -> &str { r"C:\Windows" }
    }

    #[test]
    fn flush_dns_runs_ipconfig_flushdns() {
        let mut commands = FakeCommandRunner::new();
        let result = flush_dns(&mut commands);
        assert!(result.succeeded);
        assert!(commands
            .calls
            .iter()
            .any(|(p, a)| p == "ipconfig.exe" && a == &["/flushdns"]));
    }

    #[test]
    fn reset_firewall_runs_netsh_advfirewall_reset() {
        let mut commands = FakeCommandRunner::new();
        let result = reset_firewall(&mut commands);
        assert!(result.succeeded);
        assert!(commands
            .calls
            .iter()
            .any(|(p, a)| p == "netsh.exe" && a.iter().any(|s| s == "advfirewall")));
    }

    #[test]
    fn run_sfc_runs_sfc_scannow() {
        let mut commands = FakeCommandRunner::new();
        let result = run_sfc(&mut commands);
        assert!(result.succeeded);
        assert!(commands
            .calls
            .iter()
            .any(|(p, a)| p == "sfc.exe" && a == &["/scannow"]));
    }

    #[test]
    fn run_dism_runs_dism_restorehealth() {
        let mut commands = FakeCommandRunner::new();
        let result = run_dism(&mut commands);
        assert!(result.succeeded);
        assert!(commands
            .calls
            .iter()
            .any(|(p, a)| p == "DISM.exe" && a.iter().any(|s| s == "/RestoreHealth")));
    }

    #[test]
    fn empty_recycle_bin_calls_powershell_clear_recyclebin() {
        let mut commands = FakeCommandRunner::new();
        let result = empty_recycle_bin(&mut commands);
        assert!(result.succeeded);
        assert!(commands
            .calls
            .iter()
            .any(|(p, a)| p == "powershell.exe" && a.iter().any(|s| s.contains("Clear-RecycleBin"))));
    }

    #[test]
    fn clean_temp_dirs_deletes_temp_contents_and_reports_count() {
        let mut fs = FakeFileSystem::new();
        fs.add_file(r"C:\Users\bob\AppData\Local\Temp\foo.tmp", None);
        fs.add_file(r"C:\Users\bob\AppData\Local\Temp\bar.tmp", None);
        fs.add_file(r"C:\Windows\Temp\baz.tmp", None);

        let result = clean_temp_dirs(&mut fs, &FakeDirs);

        assert!(result.succeeded);
        assert!(result.description.contains('3'));
    }

    #[test]
    fn clean_temp_dirs_skips_already_absent_entries() {
        let mut fs = FakeFileSystem::new();
        // Empty temp dirs — nothing to delete.
        let result = clean_temp_dirs(&mut fs, &FakeDirs);
        assert!(result.succeeded);
        assert!(result.description.contains('0'));
    }

    #[test]
    fn reset_winsock_calls_netsh_winsock_reset() {
        let mut commands = FakeCommandRunner::new();
        let result = reset_winsock(&mut commands);
        assert!(result.succeeded);
        assert!(commands
            .calls
            .iter()
            .any(|(p, a)| p == "netsh.exe" && a.iter().any(|s| s == "winsock")));
    }

    #[test]
    fn reset_hosts_file_calls_powershell_with_hosts_path() {
        let mut commands = FakeCommandRunner::new();
        let result = reset_hosts_file(&mut commands, &FakeDirs);
        assert!(result.succeeded);
        assert!(commands
            .calls
            .iter()
            .any(|(p, a)| p == "powershell.exe" && a.iter().any(|s| s.contains("hosts"))));
    }

    #[test]
    fn remove_proxy_disables_proxy_in_registry_and_resets_winhttp() {
        let mut registry = FakeRegistry::new();
        let mut commands = FakeCommandRunner::new();
        let result = remove_proxy(&mut registry, &mut commands);
        assert!(result.succeeded);
        assert!(registry
            .written_dwords
            .iter()
            .any(|(k, v, d)| k.contains("Internet Settings") && v == "ProxyEnable" && *d == 0));
        assert!(commands
            .calls
            .iter()
            .any(|(p, a)| p == "netsh.exe" && a.iter().any(|s| s == "winhttp")));
    }

    #[test]
    fn reset_browser_policies_deletes_found_policy_keys() {
        let mut registry = FakeRegistry::new();
        registry.add_key(r"HKLM\SOFTWARE\Policies\Google\Chrome");
        registry.add_key(r"HKLM\SOFTWARE\Policies\Microsoft\Edge");
        let result = reset_browser_policies(&mut registry);
        assert!(result.succeeded);
        assert!(result.description.contains('2'));
        assert!(registry.deleted_keys.iter().any(|k| k.contains("Chrome")));
        assert!(registry.deleted_keys.iter().any(|k| k.contains("Edge")));
    }

    #[test]
    fn reset_browser_policies_succeeds_with_zero_keys_present() {
        let mut registry = FakeRegistry::new();
        let result = reset_browser_policies(&mut registry);
        assert!(result.succeeded);
        assert!(result.description.contains('0'));
    }

    #[test]
    fn restore_file_associations_calls_reg_for_exe_bat_com_lnk() {
        let mut commands = FakeCommandRunner::new();
        let result = restore_file_associations(&mut commands);
        assert!(result.succeeded);
        assert!(commands
            .calls
            .iter()
            .any(|(p, a)| p == "reg.exe" && a.iter().any(|s| s.contains(".exe"))));
        assert!(commands
            .calls
            .iter()
            .any(|(p, a)| p == "reg.exe" && a.iter().any(|s| s.contains(".bat"))));
        assert!(commands
            .calls
            .iter()
            .any(|(p, a)| p == "reg.exe" && a.iter().any(|s| s.contains(".lnk"))));
    }
}
