//! Registry backup — the counterpart of `CreateBackupRegistry` in
//! `src/kp_includes/functions/backup.au3`. The original creates a VSS
//! shadow copy of the system drive, assigns it a drive letter via an
//! embedded, hex-encoded `dosdev.exe`, and copies the `SOFTWARE` and
//! `NTUSER.DAT` hive files out of it (falling back to a bundled
//! `HoboCopy.exe` if VSS fails). This instead uses `RegSaveKeyExW`
//! (`kprm-windows`), a native Win32 API built exactly for exporting a
//! live registry hive to a file — no VSS shadow copy, no embedded or
//! bundled third-party binary needed.

use crate::ports::Registry;

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct BackupResult {
    pub description: String,
    pub succeeded: bool,
}

/// The two hives the original backed up, and the filename each gets
/// under the backup folder — matching its own naming (`SOFTWARE`,
/// `NTUSER.DAT`), so the result is restorable the same way (offline,
/// by copying back into `%WINDIR%\System32\config` or the user's
/// profile, or loaded with `reg load` for inspection).
const TARGETS: &[(&str, &str)] = &[("HKLM\\SOFTWARE", "SOFTWARE"), ("HKCU", "NTUSER.DAT")];

/// Where this run's registry backup goes: `<home_drive>\KPRM\backup\
/// <timestamp>`, mirroring the original's `%HOMEDRIVE%\KPRM\backup\...`.
/// The caller must create this directory for real before calling
/// [`backup_registry`] — `RegSaveKeyExW` never creates one itself.
pub fn backup_dir(home_drive: &str, timestamp: &str) -> String {
    format!("{home_drive}\\KPRM\\backup\\{timestamp}")
}

/// Exports `HKEY_LOCAL_MACHINE\SOFTWARE` and the current user's hive
/// (`HKEY_CURRENT_USER`) into `dir`.
pub fn backup_registry(registry: &mut dyn Registry, dir: &str) -> Vec<BackupResult> {
    TARGETS
        .iter()
        .map(|(key, file_name)| {
            let file_path = format!("{dir}\\{file_name}");
            let succeeded = registry.save_key_to_file(key, &file_path);
            BackupResult {
                description: format!("{key} → {file_path}"),
                succeeded,
            }
        })
        .collect()
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::fakes::FakeRegistry;

    #[test]
    fn backup_dir_matches_the_original_layout() {
        assert_eq!(
            backup_dir("C:", "20260905113716"),
            r"C:\KPRM\backup\20260905113716"
        );
    }

    #[test]
    fn backup_registry_saves_both_hives_under_the_expected_names() {
        let mut registry = FakeRegistry::new();

        let results = backup_registry(&mut registry, r"C:\KPRM\backup\20260905113716");

        assert_eq!(results.len(), 2);
        assert!(results.iter().all(|r| r.succeeded));
        assert!(registry.saved_keys.contains(&(
            "HKLM\\SOFTWARE".to_string(),
            r"C:\KPRM\backup\20260905113716\SOFTWARE".to_string()
        )));
        assert!(registry.saved_keys.contains(&(
            "HKCU".to_string(),
            r"C:\KPRM\backup\20260905113716\NTUSER.DAT".to_string()
        )));
    }

    #[test]
    fn backup_registry_reports_failure_when_saving_fails() {
        let mut registry = FakeRegistry::new();
        registry.save_key_to_file_succeeds = false;

        let results = backup_registry(&mut registry, r"C:\KPRM\backup\x");

        assert!(results.iter().all(|r| !r.succeeded));
    }
}
