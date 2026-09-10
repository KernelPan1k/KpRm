//! Deleting `kprm.exe` itself after a successful real run — the
//! counterpart of the original's own self-deletion
//! (`src/kpRm.au3`/spec §2.2–2.3: a 5s-delayed `del` via `cmd.exe`, or
//! `MoveFileEx(..., MOVEFILE_DELAY_UNTIL_REBOOT)` when a restart is
//! already pending instead). Confirmed explicitly with the user before
//! implementing, since it means every real run — including one used just
//! to try the tool out — removes the exe from disk afterward.

use std::os::windows::process::CommandExt;

use crate::filesystem::schedule_delete_on_reboot;

/// Prevents a console window from flashing up for the delayed-delete
/// helper, matching every other background command this crate spawns.
const CREATE_NO_WINDOW: u32 = 0x0800_0000;

/// Deletes this running executable after a successful real run
/// ("Exécuter"/"Supprimer la sélection", never after a plain scan).
/// `needs_restart` picks the mechanism: if a restart is already pending
/// (something is `ScheduledOnReboot`), the exe's own deletion is folded
/// into that same next-boot cleanup; otherwise a short-delayed
/// `cmd.exe` helper deletes it a few seconds after this process exits —
/// Windows won't let a running exe delete its own image file directly,
/// but a file with no more open handles can be deleted the moment the
/// process holding it closes.
pub fn schedule_self_deletion(needs_restart: bool) {
    let Ok(path) = std::env::current_exe() else {
        return;
    };
    let Some(path) = path.to_str() else {
        return;
    };

    if needs_restart {
        schedule_delete_on_reboot(path);
        return;
    }

    let _ = std::process::Command::new("cmd.exe")
        .args([
            "/c",
            &format!("ping 127.0.0.1 -n 4 >nul & del /f /q \"{path}\""),
        ])
        .creation_flags(CREATE_NO_WINDOW)
        .spawn();
}
