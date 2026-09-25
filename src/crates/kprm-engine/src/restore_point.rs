//! Creating/clearing/listing Windows System Restore points, the
//! counterpart of `CreateRestorePoint`/`ClearRestorePoint`/
//! `ShowCurrentRestorePoint` in `src/kp_includes/functions/
//! system_restore.au3`. Where the original juggled three fallback
//! mechanisms for creation (`wmic`, a raw `SrClient.dll` call,
//! `Checkpoint-Computer`) and enumerated every restore point via WMI COM
//! calls, this sticks to the documented PowerShell cmdlets throughout —
//! simpler, and no less reliable in practice (creation still fails the
//! same way when System Restore is disabled by policy).
//!
//! Windows silently no-ops `Checkpoint-Computer` if a restore point
//! (created by anything — Windows Update, a driver install, an earlier
//! run of this very tool) already exists from the last ~24h
//! (`SystemRestorePointCreationFrequency`, in minutes, under
//! `HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore`;
//! default 1440). The original defeated this by deleting today's restore
//! points first (`ClearDailyRestorePoint`) before retrying; this instead
//! sets that frequency to `0` before creating one, so a "KpRm" point gets
//! created every time regardless of what already exists today — simpler,
//! and it doesn't touch (let alone delete) any existing restore point.

use crate::ports::{CommandRunner, Registry};

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct RestorePointResult {
    pub description: &'static str,
    pub succeeded: bool,
}

const POWERSHELL_PREFIX: &[&str] = &["-NoProfile", "-ExecutionPolicy", "Bypass", "-Command"];
const SYSTEM_RESTORE_KEY: &str = r"HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore";

fn run_powershell(commands: &mut dyn CommandRunner, script: &str) -> bool {
    let mut args = POWERSHELL_PREFIX.to_vec();
    args.push(script);
    commands.run("powershell.exe", &args)
}

/// Enables System Restore on the system drive, lifts the once-a-day
/// creation throttle, then creates a "KpRm" restore point.
pub fn create_restore_point(
    commands: &mut dyn CommandRunner,
    registry: &mut dyn Registry,
) -> Vec<RestorePointResult> {
    vec![
        RestorePointResult {
            description: "enable System Restore protection",
            succeeded: run_powershell(
                commands,
                r#"Enable-ComputerRestore -Drive "$env:SystemDrive\""#,
            ),
        },
        RestorePointResult {
            description: "lift the one-restore-point-per-day limit",
            succeeded: registry.write_dword(
                SYSTEM_RESTORE_KEY,
                "SystemRestorePointCreationFrequency",
                0,
            ),
        },
        RestorePointResult {
            description: "create the restore point",
            succeeded: run_powershell(
                commands,
                "Checkpoint-Computer -Description 'KpRm' -RestorePointType MODIFY_SETTINGS",
            ),
        },
    ]
}

/// Clears every existing restore point on the system drive by cycling
/// System Restore off then on — the documented, DLL-free way to wipe them
/// all at once (there is no stock cmdlet to remove a single point;
/// `SRRemoveRestorePoint`, which the original called directly, requires a
/// raw `SrClient.dll` call this avoids).
pub fn remove_all_restore_points(commands: &mut dyn CommandRunner) -> RestorePointResult {
    RestorePointResult {
        description: "remove the restore points",
        succeeded: run_powershell(
            commands,
            r#"Disable-ComputerRestore -Drive "$env:SystemDrive\"; Enable-ComputerRestore -Drive "$env:SystemDrive\""#,
        ),
    }
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct RestorePointInfo {
    pub sequence_number: String,
    pub description: String,
    pub created_at: String,
}

const LIST_SCRIPT: &str = "Get-ComputerRestorePoint | ForEach-Object { '{0}|{1}|{2}' -f \
     $_.SequenceNumber, $_.Description, $_.ConvertToDateTime($_.CreationTime) }";

/// Lists every System Restore point currently on the system drive, via the
/// same `Get-ComputerRestorePoint` cmdlet the original's PowerShell
/// fallback used (`SR_EnumRestorePointsPowershell` in
/// `system_restore.au3`) — going through WMI directly, like the original
/// tried first, would need a COM crate this avoids. Returns an empty list
/// both when there genuinely are none and when the command itself fails
/// (System Restore disabled, PowerShell unavailable) — the caller can't
/// tell those apart from this alone, matching how little the original's
/// own enumeration distinguished them either.
///
/// Each line is `sequence|description|date`; a description containing a
/// literal `|` would be misparsed. Restore point descriptions essentially
/// never contain one in practice, and never do for the "KpRm" points this
/// module itself creates.
pub fn list_restore_points(commands: &mut dyn CommandRunner) -> Vec<RestorePointInfo> {
    let mut args = POWERSHELL_PREFIX.to_vec();
    args.push(LIST_SCRIPT);
    let Some(output) = commands.run_capture("powershell.exe", &args) else {
        return Vec::new();
    };

    output
        .lines()
        .filter_map(|line| {
            let mut parts = line.splitn(3, '|');
            let sequence_number = parts.next()?.trim().to_string();
            let description = parts.next()?.trim().to_string();
            let created_at = parts.next()?.trim().to_string();
            (!sequence_number.is_empty()).then_some(RestorePointInfo {
                sequence_number,
                description,
                created_at,
            })
        })
        .collect()
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::fakes::{FakeCommandRunner, FakeRegistry};

    #[test]
    fn create_restore_point_enables_protection_lifts_the_throttle_then_checkpoints() {
        let mut commands = FakeCommandRunner::new();
        let mut registry = FakeRegistry::new();

        let results = create_restore_point(&mut commands, &mut registry);

        assert_eq!(results.len(), 3);
        assert!(results.iter().all(|r| r.succeeded));
        assert!(commands
            .calls
            .iter()
            .any(|(_, args)| args.iter().any(|a| a.contains("Enable-ComputerRestore"))));
        assert!(commands
            .calls
            .iter()
            .any(|(_, args)| args.iter().any(|a| a.contains("Checkpoint-Computer"))));
        assert_eq!(
            registry.read_value(SYSTEM_RESTORE_KEY, "SystemRestorePointCreationFrequency"),
            Some("0".to_string())
        );
    }

    #[test]
    fn create_restore_point_reports_failure_when_powershell_fails() {
        let mut commands = FakeCommandRunner::new();
        commands.always_succeeds = false;
        let mut registry = FakeRegistry::new();

        let results = create_restore_point(&mut commands, &mut registry);

        assert!(!results[0].succeeded); // Enable-ComputerRestore
        assert!(results[1].succeeded); // registry write, unaffected by the fake command runner
        assert!(!results[2].succeeded); // Checkpoint-Computer
    }

    #[test]
    fn remove_all_restore_points_disables_then_reenables_protection() {
        let mut commands = FakeCommandRunner::new();

        let result = remove_all_restore_points(&mut commands);

        assert!(result.succeeded);
        let (_, args) = &commands.calls[0];
        let script = args.last().unwrap();
        assert!(script.contains("Disable-ComputerRestore"));
        assert!(script.contains("Enable-ComputerRestore"));
    }

    #[test]
    fn list_restore_points_parses_each_pipe_delimited_line() {
        let mut commands = FakeCommandRunner::new();
        commands.captured_stdout = Some(
            "12|KpRm|09/04/2026 21:32:00\r\n13|Windows Update|09/03/2026 08:00:00\r\n".to_string(),
        );

        let points = list_restore_points(&mut commands);

        assert_eq!(points.len(), 2);
        assert_eq!(points[0].sequence_number, "12");
        assert_eq!(points[0].description, "KpRm");
        assert_eq!(points[0].created_at, "09/04/2026 21:32:00");
        assert_eq!(points[1].description, "Windows Update");
    }

    #[test]
    fn list_restore_points_is_empty_when_the_command_fails() {
        let mut commands = FakeCommandRunner::new();
        commands.always_succeeds = false;

        assert!(list_restore_points(&mut commands).is_empty());
    }

    #[test]
    fn list_restore_points_is_empty_when_there_are_none() {
        let mut commands = FakeCommandRunner::new();
        commands.captured_stdout = Some(String::new());

        assert!(list_restore_points(&mut commands).is_empty());
    }
}
