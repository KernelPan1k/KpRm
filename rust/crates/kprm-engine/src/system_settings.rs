//! Resetting network settings and a handful of Explorer display options,
//! ported from `RestoreSystemSettingsByDefault` in
//! `src/kp_includes/functions/system_settings.au3`. See
//! docs/RUST-REWRITE-SPEC.md §2.14.

use crate::ports::{CommandRunner, ProcessManager, Registry};

const NETSH_COMMANDS: &[&[&str]] = &[
    &["winsock", "reset"],
    &["winhttp", "reset", "proxy"],
    &["winhttp", "reset", "tracing"],
    &["winsock", "reset", "catalog"],
    &["int", "ip", "reset", "all"],
    &["int", "ipv4", "reset", "catalog"],
    &["int", "ipv6", "reset", "catalog"],
];

const EXPLORER_ADVANCED_KEY: &str =
    r"HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced";

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct SettingsRestoreResult {
    pub description: &'static str,
    pub succeeded: bool,
}

/// Runs the `netsh`/`ipconfig` resets and rewrites the three Explorer
/// "show hidden/system files, hide known extensions" values to their
/// Windows defaults. Restarting `explorer.exe` (needed for the Explorer
/// changes to take visible effect immediately) is left to the caller —
/// see `kprm-windows`, which has the real process ports to do it safely.
pub fn restore_defaults(
    registry: &mut dyn Registry,
    commands: &mut dyn CommandRunner,
) -> Vec<SettingsRestoreResult> {
    let mut results = Vec::new();

    for args in NETSH_COMMANDS {
        results.push(SettingsRestoreResult {
            description: "netsh reset",
            succeeded: commands.run("netsh.exe", args),
        });
    }
    results.push(SettingsRestoreResult {
        description: "flush DNS",
        succeeded: commands.run("ipconfig.exe", &["/flushdns"]),
    });

    results.push(SettingsRestoreResult {
        description: "hide hidden files",
        succeeded: registry.write_dword(EXPLORER_ADVANCED_KEY, "Hidden", 2),
    });
    results.push(SettingsRestoreResult {
        description: "show known file extensions",
        succeeded: registry.write_dword(EXPLORER_ADVANCED_KEY, "HideFileExt", 0),
    });
    results.push(SettingsRestoreResult {
        description: "hide protected operating system files",
        succeeded: registry.write_dword(EXPLORER_ADVANCED_KEY, "ShowSuperHidden", 0),
    });

    results
}

/// Restarts `explorer.exe` so the Explorer setting changes above apply
/// immediately, exactly like `_Restart_Windows_Explorer` in
/// `src/kp_includes/functions/utils.au3`.
pub fn restart_explorer(processes: &mut dyn ProcessManager, commands: &mut dyn CommandRunner) {
    let explorer_pids: Vec<u32> = processes
        .list()
        .into_iter()
        .filter(|p| p.name.eq_ignore_ascii_case("explorer.exe"))
        .map(|p| p.pid)
        .collect();

    for pid in explorer_pids {
        processes.kill(pid);
    }

    commands.run("explorer.exe", &[]);
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::fakes::{FakeCommandRunner, FakeProcessManager, FakeRegistry};

    #[test]
    fn runs_every_netsh_reset_and_flushes_dns() {
        let mut registry = FakeRegistry::new();
        let mut commands = FakeCommandRunner::new();

        restore_defaults(&mut registry, &mut commands);

        let netsh_calls: Vec<_> = commands
            .calls
            .iter()
            .filter(|(program, _)| program == "netsh.exe")
            .collect();
        assert_eq!(netsh_calls.len(), 7);
        assert!(commands
            .calls
            .iter()
            .any(|(p, a)| p == "ipconfig.exe" && a == &["/flushdns"]));
    }

    #[test]
    fn writes_the_three_explorer_defaults() {
        let mut registry = FakeRegistry::new();
        let mut commands = FakeCommandRunner::new();

        restore_defaults(&mut registry, &mut commands);

        assert_eq!(
            registry.read_value(EXPLORER_ADVANCED_KEY, "Hidden"),
            Some("2".to_string())
        );
        assert_eq!(
            registry.read_value(EXPLORER_ADVANCED_KEY, "HideFileExt"),
            Some("0".to_string())
        );
        assert_eq!(
            registry.read_value(EXPLORER_ADVANCED_KEY, "ShowSuperHidden"),
            Some("0".to_string())
        );
    }

    #[test]
    fn restart_explorer_kills_every_explorer_process_then_relaunches_it() {
        let mut processes = FakeProcessManager::new();
        processes.add(100, "explorer.exe", None);
        processes.add(200, "notepad.exe", None);
        let mut commands = FakeCommandRunner::new();

        restart_explorer(&mut processes, &mut commands);

        assert!(processes.killed.contains(&100));
        assert!(!processes.killed.contains(&200));
        assert!(commands.calls.iter().any(|(p, _)| p == "explorer.exe"));
    }
}
