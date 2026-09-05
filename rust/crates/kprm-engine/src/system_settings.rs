//! Resetting network settings and a handful of Explorer display options,
//! ported from `RestoreSystemSettingsByDefault` in
//! `src/kp_includes/functions/system_settings.au3`. See
//! docs/RUST-REWRITE-SPEC.md §2.14.

use crate::ports::{CommandRunner, ProcessManager, Registry};

struct NetshCommand {
    args: &'static [&'static str],
    label: &'static str,
}

/// `netsh interface ip/ipv4/ipv6 reset` iterate over many independent
/// sub-items (routing, neighbor cache, WFP filters, ...); it's normal —
/// even fully elevated — for exactly one of them to refuse with "the
/// requested operation requires elevation" while the rest succeed, a
/// known Windows quirk unrelated to how this process was launched. The
/// overall exit code still goes non-zero when that happens, so this is
/// still reported as a failure, but with `netsh`'s own real output
/// attached instead of a bare unexplained "[X]".
const NETSH_COMMANDS: &[NetshCommand] = &[
    NetshCommand {
        args: &["winsock", "reset"],
        label: "netsh winsock reset",
    },
    NetshCommand {
        args: &["winhttp", "reset", "proxy"],
        label: "netsh winhttp reset proxy",
    },
    NetshCommand {
        args: &["winhttp", "reset", "tracing"],
        label: "netsh winhttp reset tracing",
    },
    NetshCommand {
        args: &["winsock", "reset", "catalog"],
        label: "netsh winsock reset catalog",
    },
    NetshCommand {
        args: &["int", "ip", "reset", "all"],
        label: "netsh interface ip reset",
    },
    NetshCommand {
        args: &["int", "ipv4", "reset", "catalog"],
        label: "netsh interface ipv4 reset",
    },
    NetshCommand {
        args: &["int", "ipv6", "reset", "catalog"],
        label: "netsh interface ipv6 reset",
    },
];

/// How much of `netsh`'s own (possibly long, multi-line) output to keep
/// in a failure's description.
const FAILURE_SNIPPET_MAX_CHARS: usize = 200;

const EXPLORER_ADVANCED_KEY: &str =
    r"HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced";

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct SettingsRestoreResult {
    pub description: String,
    pub succeeded: bool,
}

/// Flattens `output` to one line and truncates it, so a `netsh` failure's
/// real reason fits in a report row without breaking its formatting or
/// running on for a whole multi-line per-item reset log.
fn failure_snippet(output: &str) -> Option<String> {
    let flat: String = output.split_whitespace().collect::<Vec<_>>().join(" ");
    if flat.is_empty() {
        return None;
    }
    if flat.chars().count() > FAILURE_SNIPPET_MAX_CHARS {
        let truncated: String = flat.chars().take(FAILURE_SNIPPET_MAX_CHARS).collect();
        Some(format!("{truncated}…"))
    } else {
        Some(flat)
    }
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

    for cmd in NETSH_COMMANDS {
        let (succeeded, output) = commands.run_with_output("netsh.exe", cmd.args);
        let description = if succeeded {
            cmd.label.to_string()
        } else {
            match failure_snippet(&output) {
                Some(snippet) => format!("{} : {snippet}", cmd.label),
                None => cmd.label.to_string(),
            }
        };
        results.push(SettingsRestoreResult {
            description,
            succeeded,
        });
    }
    results.push(SettingsRestoreResult {
        description: "flush DNS".to_string(),
        succeeded: commands.run("ipconfig.exe", &["/flushdns"]),
    });

    results.push(SettingsRestoreResult {
        description: "hide hidden files".to_string(),
        succeeded: registry.write_dword(EXPLORER_ADVANCED_KEY, "Hidden", 2),
    });
    results.push(SettingsRestoreResult {
        description: "show known file extensions".to_string(),
        succeeded: registry.write_dword(EXPLORER_ADVANCED_KEY, "HideFileExt", 0),
    });
    results.push(SettingsRestoreResult {
        description: "hide protected operating system files".to_string(),
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
    fn netsh_descriptions_name_the_actual_command_when_successful() {
        let mut registry = FakeRegistry::new();
        let mut commands = FakeCommandRunner::new();

        let results = restore_defaults(&mut registry, &mut commands);

        assert!(results
            .iter()
            .any(|r| r.description == "netsh winsock reset" && r.succeeded));
        assert!(results
            .iter()
            .any(|r| r.description == "netsh interface ipv6 reset" && r.succeeded));
    }

    #[test]
    fn netsh_descriptions_include_the_real_failure_reason() {
        let mut registry = FakeRegistry::new();
        let mut commands = FakeCommandRunner::new();
        commands.always_succeeds = false;
        commands.captured_stdout = Some("L'opération demandée requiert une élévation".to_string());

        let results = restore_defaults(&mut registry, &mut commands);

        assert!(results.iter().any(|r| {
            !r.succeeded
                && r.description.starts_with("netsh winsock reset :")
                && r.description.contains("requiert une élévation")
        }));
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
