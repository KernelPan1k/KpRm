//! Restoring a previous registry-hive backup (see [`kprm_engine::backup`])
//! over the live hive files. New feature — the original AutoIt tool only
//! ever backed up hives, it never offered a way to put one back.
//!
//! Both `HKLM\SOFTWARE` and the current user's `NTUSER.DAT` are always
//! open while Windows is running, so this doesn't call `RegRestoreKeyW`
//! live against them (unreliable, and genuinely dangerous on a hive that's
//! mounted system-wide — countless processes hold open handles into
//! `SOFTWARE`). Instead this schedules a delayed on-disk file replacement
//! (see [`crate::filesystem::schedule_replace_on_reboot`]), the same
//! "pending file rename operation" mechanism tools like ERUNT have used
//! for decades to restore hives offline. A restart is required for it to
//! actually take effect — the caller must offer one (see
//! [`kprm_engine::report::EventResult::ScheduledOnReboot`]).
//!
//! Not unit-tested against the real OS: like [`crate::self_delete`], the
//! only way to verify this for real is to actually reboot and check the
//! hive changed, which no test suite should do — there's also no clean
//! way to cancel one specific pending-rename entry afterward without
//! risking corrupting whatever else is legitimately pending.

use kprm_engine::backup::{AvailableBackup, RestoreTarget};
use kprm_engine::paths::KnownDirs;

use crate::filesystem::schedule_replace_on_reboot;

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct RestoreOutcome {
    pub description: String,
    pub scheduled: bool,
}

/// Lists every backup previously created by "Sauvegarder le registre"
/// (Automatic tab), most recent first.
pub fn list_registry_backups(dirs: &dyn KnownDirs) -> Vec<AvailableBackup> {
    kprm_engine::backup::list_backups(&crate::filesystem::WinFileSystem, dirs.home_drive())
}

/// Schedules every target's backup file to replace its live hive file at
/// next boot. Reports a target unscheduled (rather than scheduling a
/// replace with a missing source, which would silently do nothing at
/// boot anyway) when its backup file doesn't actually exist on disk.
pub fn schedule_registry_restore(targets: &[RestoreTarget]) -> Vec<RestoreOutcome> {
    targets
        .iter()
        .map(|target| {
            let exists = std::path::Path::new(&target.backup_file).is_file();
            let scheduled =
                exists && schedule_replace_on_reboot(&target.backup_file, &target.live_file);
            RestoreOutcome {
                description: target.description.clone(),
                scheduled,
            }
        })
        .collect()
}
