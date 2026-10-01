//! Deleting `kprm.exe` itself after the Automatic tab's real run — the
//! counterpart of the original's own self-deletion (`src/kpRm.au3`/spec
//! §2.2–2.3: a 5s-delayed `del` via `cmd.exe`, or `MoveFileEx(...,
//! MOVEFILE_DELAY_UNTIL_REBOOT)` when a restart is already pending
//! instead). Confirmed explicitly with the user: only that flow
//! self-deletes — a plain scan or the Custom tab's "Supprimer la
//! sélection" (meant for iterative search-then-remove use) never call
//! this.

use std::os::windows::process::CommandExt;

use crate::filesystem::schedule_delete_on_reboot;

/// Prevents a console window from flashing up for the delayed-delete
/// helper, matching every other background command this crate spawns.
const CREATE_NO_WINDOW: u32 = 0x0800_0000;

/// Deletes this running executable after a real run.
/// `needs_restart` picks the mechanism: if a restart is already pending
/// (something is `ScheduledOnReboot`), the exe's own deletion is folded
/// into that same next-boot cleanup; otherwise a short-delayed `cmd.exe`
/// helper deletes it a few seconds after this process exits — Windows
/// won't let a running exe delete its own image file directly, but a
/// file with no more open handles can be deleted the moment the process
/// holding it closes.
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

    // Confirmed on a real machine: a single `cmd.exe /c "ping ... & del
    // /f /q \"{path}\""` argument — one quoted string nested inside
    // another — hits a well-known `cmd.exe /c` quirk (it only preserves
    // nested quotes when there are *exactly* two quote characters on the
    // line; this one has four) and silently fails to delete anything.
    // Routing the same two commands through a tiny generated `.bat` file
    // instead sidesteps that entirely: `cmd.exe /c "<bat path>"` is a
    // single, ordinary quoted path (any spaces in it, none elsewhere),
    // so there's no nested-quote parsing left to get wrong. The script
    // deletes itself as its last line too, so nothing is left behind in
    // `%TEMP%` (cmd.exe prints a harmless "command file not found" after
    // that self-delete, from trying to read past the now-gone file — not
    // visible to the user, since this GUI has no console to print it to).
    let Some(bat_path) = write_delete_script(path) else {
        return;
    };
    let _ = std::process::Command::new("cmd.exe")
        .args(["/c", &bat_path])
        .creation_flags(CREATE_NO_WINDOW)
        .spawn();
}

fn write_delete_script(target_path: &str) -> Option<String> {
    let bat_path = std::env::temp_dir().join(format!("kprm-self-delete-{}.bat", std::process::id()));
    let script = format!(
        "@echo off\r\nping 127.0.0.1 -n 4 >nul\r\ndel /f /q \"{target_path}\"\r\ndel /f /q \"%~f0\"\r\n"
    );
    std::fs::write(&bat_path, script).ok()?;
    bat_path.to_str().map(str::to_string)
}
