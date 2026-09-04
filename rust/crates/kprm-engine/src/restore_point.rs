//! Creating/clearing Windows System Restore points, the counterpart of
//! `CreateRestorePoint`/`ClearRestorePoint` in
//! `src/kp_includes/functions/system_restore.au3`. Where the original
//! juggled three fallback mechanisms (`wmic`, a raw `SrClient.dll` call,
//! `Checkpoint-Computer`) and enumerated every restore point's WMI name
//! and date individually, this sticks to the two documented PowerShell
//! cmdlets and reports one overall success/failure per action instead —
//! simpler, and no less reliable in practice (creation still fails the
//! same way when System Restore is disabled by policy or Windows' own
//! once-a-day throttling already refused one today).

use crate::ports::CommandRunner;

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct RestorePointResult {
    pub description: &'static str,
    pub succeeded: bool,
}

const POWERSHELL_PREFIX: &[&str] = &["-NoProfile", "-ExecutionPolicy", "Bypass", "-Command"];

fn run_powershell(commands: &mut dyn CommandRunner, script: &str) -> bool {
    let mut args = POWERSHELL_PREFIX.to_vec();
    args.push(script);
    commands.run("powershell.exe", &args)
}

/// Enables System Restore on the system drive, then creates a "KpRm"
/// restore point.
pub fn create_restore_point(commands: &mut dyn CommandRunner) -> Vec<RestorePointResult> {
    vec![
        RestorePointResult {
            description: "activer la protection du système",
            succeeded: run_powershell(
                commands,
                r#"Enable-ComputerRestore -Drive "$env:SystemDrive\""#,
            ),
        },
        RestorePointResult {
            description: "créer le point de restauration",
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
        description: "supprimer les points de restauration",
        succeeded: run_powershell(
            commands,
            r#"Disable-ComputerRestore -Drive "$env:SystemDrive\"; Enable-ComputerRestore -Drive "$env:SystemDrive\""#,
        ),
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::fakes::FakeCommandRunner;

    #[test]
    fn create_restore_point_enables_protection_then_checkpoints() {
        let mut commands = FakeCommandRunner::new();

        let results = create_restore_point(&mut commands);

        assert_eq!(results.len(), 2);
        assert!(results.iter().all(|r| r.succeeded));
        assert!(commands
            .calls
            .iter()
            .any(|(_, args)| args.iter().any(|a| a.contains("Enable-ComputerRestore"))));
        assert!(commands
            .calls
            .iter()
            .any(|(_, args)| args.iter().any(|a| a.contains("Checkpoint-Computer"))));
    }

    #[test]
    fn create_restore_point_reports_failure_when_powershell_fails() {
        let mut commands = FakeCommandRunner::new();
        commands.always_succeeds = false;

        let results = create_restore_point(&mut commands);

        assert!(results.iter().all(|r| !r.succeeded));
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
}
