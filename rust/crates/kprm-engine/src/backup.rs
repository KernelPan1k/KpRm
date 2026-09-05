//! Registry backup — the counterpart of `CreateBackupRegistry` in
//! `src/kp_includes/functions/backup.au3`. The original creates a VSS
//! shadow copy of the system drive, assigns it a drive letter via an
//! embedded, hex-encoded `dosdev.exe`, and copies the `SOFTWARE` and
//! `NTUSER.DAT` hive files out of it (falling back to a bundled
//! `HoboCopy.exe` if VSS fails). This instead uses `RegSaveKeyExW`
//! (`kprm-windows`), a native Win32 API built exactly for exporting a
//! live registry hive to a file — no VSS shadow copy, no embedded or
//! bundled third-party binary needed.

use kprm_catalog::EntryKind;

use crate::paths::KnownDirs;
use crate::ports::{FileSystem, Registry};

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct BackupResult {
    pub description: String,
    pub succeeded: bool,
}

/// One previous registry backup found under `<home_drive>\KPRM\backup\`,
/// ready to be offered back to the user in the "Outils +" tab.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct AvailableBackup {
    /// The backup's timestamp (its folder name), e.g. `20260905113716`.
    pub timestamp: String,
    /// The full path to the backup folder.
    pub dir: String,
    pub has_software: bool,
    pub has_ntuser: bool,
}

/// One hive to put back in place: which backup file goes over which live
/// hive file. Restoring it for real needs `kprm-windows`'s
/// `schedule_registry_restore` — both hives are always open while Windows
/// is running, so this can only take effect at the next boot.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct RestoreTarget {
    pub description: String,
    pub backup_file: String,
    pub live_file: String,
}

/// Lists every backup [`backup_registry`] has previously created, most
/// recent first — the folder name is a `current_timestamp()` value, so
/// this sorts lexicographically the same as chronologically.
pub fn list_backups(fs: &dyn FileSystem, home_drive: &str) -> Vec<AvailableBackup> {
    let root = format!("{home_drive}\\KPRM\\backup");
    let mut backups: Vec<AvailableBackup> = fs
        .list_dir(&root, 1)
        .into_iter()
        .filter(|path| fs.kind(path) == Some(EntryKind::Folder))
        .filter_map(|dir| {
            let timestamp = dir.rsplit('\\').next()?.to_string();
            let has_software = fs.kind(&format!("{dir}\\SOFTWARE")) == Some(EntryKind::File);
            let has_ntuser = fs.kind(&format!("{dir}\\NTUSER.DAT")) == Some(EntryKind::File);
            if !has_software && !has_ntuser {
                return None;
            }
            Some(AvailableBackup {
                timestamp,
                dir,
                has_software,
                has_ntuser,
            })
        })
        .collect();
    backups.sort_by(|a, b| b.timestamp.cmp(&a.timestamp));
    backups
}

/// Builds the restore plan for one previously-listed backup: which backup
/// file goes back over which live hive file.
pub fn restore_plan(backup: &AvailableBackup, dirs: &dyn KnownDirs) -> Vec<RestoreTarget> {
    let mut targets = Vec::new();
    if backup.has_software {
        targets.push(RestoreTarget {
            description: "HKLM\\SOFTWARE".to_string(),
            backup_file: format!("{}\\SOFTWARE", backup.dir),
            live_file: format!("{}\\System32\\config\\SOFTWARE", dirs.windows_dir()),
        });
    }
    if backup.has_ntuser {
        targets.push(RestoreTarget {
            description: "HKCU (NTUSER.DAT)".to_string(),
            backup_file: format!("{}\\NTUSER.DAT", backup.dir),
            live_file: format!("{}\\NTUSER.DAT", dirs.user_profile()),
        });
    }
    targets
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
    use crate::fakes::{FakeFileSystem, FakeKnownDirs, FakeRegistry};

    #[test]
    fn list_backups_finds_only_folders_with_at_least_one_known_hive_file() {
        let mut fs = FakeFileSystem::new();
        fs.add_folder(r"C:\KPRM\backup\20260101000000");
        fs.add_file(r"C:\KPRM\backup\20260101000000\SOFTWARE", None);
        fs.add_file(r"C:\KPRM\backup\20260101000000\NTUSER.DAT", None);
        fs.add_folder(r"C:\KPRM\backup\20260201000000");
        fs.add_file(r"C:\KPRM\backup\20260201000000\SOFTWARE", None);
        // Not a real backup (e.g. a stray empty folder) — must be skipped.
        fs.add_folder(r"C:\KPRM\backup\20260301000000");

        let backups = list_backups(&fs, "C:");

        assert_eq!(backups.len(), 2);
        // Most recent first.
        assert_eq!(backups[0].timestamp, "20260201000000");
        assert!(backups[0].has_software);
        assert!(!backups[0].has_ntuser);
        assert_eq!(backups[1].timestamp, "20260101000000");
        assert!(backups[1].has_software);
        assert!(backups[1].has_ntuser);
    }

    #[test]
    fn list_backups_is_empty_when_the_backup_root_does_not_exist() {
        let fs = FakeFileSystem::new();
        assert!(list_backups(&fs, "C:").is_empty());
    }

    #[test]
    fn restore_plan_targets_only_the_hives_the_backup_actually_has() {
        let dirs = FakeKnownDirs::default();
        let backup = AvailableBackup {
            timestamp: "20260101000000".to_string(),
            dir: r"C:\KPRM\backup\20260101000000".to_string(),
            has_software: true,
            has_ntuser: false,
        };

        let targets = restore_plan(&backup, &dirs);

        assert_eq!(targets.len(), 1);
        assert_eq!(
            targets[0].backup_file,
            r"C:\KPRM\backup\20260101000000\SOFTWARE"
        );
        assert_eq!(targets[0].live_file, r"C:\Windows\System32\config\SOFTWARE");
    }

    #[test]
    fn restore_plan_includes_ntuser_when_available() {
        let dirs = FakeKnownDirs::default();
        let backup = AvailableBackup {
            timestamp: "20260101000000".to_string(),
            dir: r"C:\KPRM\backup\20260101000000".to_string(),
            has_software: false,
            has_ntuser: true,
        };

        let targets = restore_plan(&backup, &dirs);

        assert_eq!(targets.len(), 1);
        assert_eq!(
            targets[0].backup_file,
            r"C:\KPRM\backup\20260101000000\NTUSER.DAT"
        );
        assert_eq!(targets[0].live_file, r"C:\Users\bob\NTUSER.DAT");
    }

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
