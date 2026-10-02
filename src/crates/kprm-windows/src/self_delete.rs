//! Deleting `kprm.exe` itself after the Automatic tab's real run — the
//! counterpart of the original's own self-deletion (`src/kpRm.au3`/spec
//! §2.2–2.3: a 5s-delayed `del` via `cmd.exe`, or `MoveFileEx(...,
//! MOVEFILE_DELAY_UNTIL_REBOOT)` when a restart is already pending
//! instead). Confirmed explicitly with the user: only that flow
//! self-deletes — a plain scan or the Custom tab's "Supprimer la
//! sélection" (meant for iterative search-then-remove use) never call
//! this.

use std::os::windows::process::CommandExt;

use windows::core::PCWSTR;
use windows::Win32::Storage::FileSystem::GetShortPathNameW;

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
    //
    // `cmd.exe` parses a .bat file's *bytes* using the console's OEM
    // codepage, not UTF-8 — so any non-ASCII character written into the
    // script (e.g. an accented letter in the user's own Windows profile
    // path, like "Mickaël") comes out corrupted on the `del` line, and
    // `del` then silently fails every time because the path it's reading
    // from the script no longer matches the real file on disk. Resolving
    // to the 8.3 short path first (pure ASCII, e.g. `MICKAL~1`) sidesteps
    // the whole codepage question — confirmed by reproducing the exact
    // failure (path corrupted, `del` never matches) on an account with an
    // accented username, then confirming the short path deletes cleanly.
    let short_path = to_short_path(path);
    let Some(bat_path) = write_delete_script(&short_path) else {
        return;
    };
    let _ = std::process::Command::new("cmd.exe")
        .args(["/c", &bat_path])
        .creation_flags(CREATE_NO_WINDOW)
        .spawn();
}

/// Resolves `path` to its 8.3 short form (e.g. `C:\Users\MICKAL~1\...`)
/// via `GetShortPathNameW`, falling back to `path` unchanged if that
/// fails (short-name generation can be disabled per-volume via `fsutil
/// 8dot3name`) — in that rare case the script is no worse off than
/// before this fix.
fn to_short_path(path: &str) -> String {
    let wide: Vec<u16> = path.encode_utf16().chain(std::iter::once(0)).collect();
    let mut buf = [0u16; 260];
    let len = unsafe { GetShortPathNameW(PCWSTR(wide.as_ptr()), Some(&mut buf)) };
    if len == 0 || len as usize >= buf.len() {
        return path.to_string();
    }
    String::from_utf16_lossy(&buf[..len as usize])
}

/// Retries the delete for up to ~30s (30 attempts, 1s apart) instead of
/// trying once: on a release build — unsigned, UAC-elevated, and freshly
/// built, so unlike a debug binary rebuilt constantly in dev, Defender
/// hasn't seen it before — real-time protection's on-access scan can hold
/// the file open well past a single short wait, and a one-shot `del`
/// simply fails silently when it does. Checking `exist` after each
/// attempt lets the loop exit the moment the delete actually lands,
/// instead of always running the full 30s.
fn write_delete_script(target_path: &str) -> Option<String> {
    let bat_path = std::env::temp_dir().join(format!("kprm-self-delete-{}.bat", std::process::id()));
    let script = format!(
        "@echo off\r\n\
         for /l %%i in (1,1,30) do (\r\n\
         \tdel /f /q \"{target_path}\" >nul 2>&1\r\n\
         \tif not exist \"{target_path}\" goto :done\r\n\
         \tping 127.0.0.1 -n 2 >nul\r\n\
         )\r\n\
         :done\r\n\
         del /f /q \"%~f0\"\r\n"
    );
    std::fs::write(&bat_path, script).ok()?;
    bat_path.to_str().map(str::to_string)
}

#[cfg(test)]
mod tests {
    use super::*;

    /// Regression test for a real bug: an accented character anywhere in
    /// the target path (e.g. a Windows username like "Mickaël") used to
    /// get corrupted when `cmd.exe` parsed the generated `.bat` in the
    /// OEM codepage, so `del` silently never matched the real file and
    /// the exe was never cleaned up. The filename itself carries the
    /// accent here so this fails on any machine, not just one with an
    /// accented username.
    #[test]
    fn deletes_a_file_whose_path_contains_a_non_ascii_character() {
        let target = std::env::temp_dir().join("kprm-self-delete-test-é.exe");
        std::fs::write(&target, b"dummy").unwrap();
        let target_str = target.to_str().unwrap();

        let short_path = to_short_path(target_str);
        assert!(short_path.is_ascii(), "short path should be pure ASCII: {short_path}");

        let bat_path = write_delete_script(&short_path).expect("script should be written");
        // Not asserting the exit code: cmd.exe's last line deletes the
        // very script it's reading from, which it then reports as a
        // harmless "command file not found" with a non-zero exit code —
        // documented above, and true before this fix too. What matters
        // is whether the target actually got deleted.
        let _ = std::process::Command::new("cmd.exe")
            .args(["/c", &bat_path])
            .status()
            .expect("cmd.exe should run");

        assert!(!target.exists(), "the accented-path file should have been deleted");
    }
}
