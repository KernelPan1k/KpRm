//! Real file/folder removal, ported from `RemoveTheFile`/`RemoveTheFolder`/
//! `PrepareRemove`/`ClearAttributes` in
//! `src/kp_includes/functions/{remove,utils}.au3`. See
//! docs/RUST-REWRITE-SPEC.md §3.2 and §3.6 (§3.6: unlike the original — a
//! full hand-rolled ACL reset via raw `DllCall`s before every deletion — this
//! v1 only escalates to `icacls` when a plain delete plus an attribute reset
//! both fail, which is cheaper and covers the same real-world "quarantined
//! by an AV, marked read-only/hidden/system" cases the catalog actually
//! hits).

use std::fs;
use std::path::Path;

use kprm_catalog::EntryKind;
use kprm_engine::ports::{FileSystem, Removal};
use windows::core::PCWSTR;
use windows::Win32::Storage::FileSystem::{
    GetFileAttributesW, MoveFileExW, SetFileAttributesW, FILE_ATTRIBUTE_HIDDEN,
    FILE_ATTRIBUTE_READONLY, FILE_ATTRIBUTE_SYSTEM, FILE_FLAGS_AND_ATTRIBUTES,
    MOVEFILE_DELAY_UNTIL_REBOOT,
};

const INVALID_FILE_ATTRIBUTES: u32 = u32::MAX;

fn wide(s: &str) -> Vec<u16> {
    s.encode_utf16().chain(std::iter::once(0)).collect()
}

/// Removes the read-only/hidden/system attributes from one file or folder,
/// mirroring `ClearAttributes` — the step that lets a subsequent plain
/// delete succeed for most AV-quarantined files without needing a full ACL
/// reset.
fn clear_attributes(path: &str) {
    let w = wide(path);
    unsafe {
        let attrs = GetFileAttributesW(PCWSTR(w.as_ptr()));
        if attrs == INVALID_FILE_ATTRIBUTES {
            return;
        }
        let clear_mask =
            FILE_ATTRIBUTE_READONLY.0 | FILE_ATTRIBUTE_HIDDEN.0 | FILE_ATTRIBUTE_SYSTEM.0;
        let new_attrs = attrs & !clear_mask;
        if new_attrs != attrs {
            let _ = SetFileAttributesW(PCWSTR(w.as_ptr()), FILE_FLAGS_AND_ATTRIBUTES(new_attrs));
        }
    }
}

/// Schedules `path` for deletion at next boot via
/// `MoveFileEx(..., MOVEFILE_DELAY_UNTIL_REBOOT)` — the same mechanism the
/// original used as a last resort for locked files.
fn schedule_delete_on_reboot(path: &str) {
    let w = wide(path);
    unsafe {
        let _ = MoveFileExW(
            PCWSTR(w.as_ptr()),
            PCWSTR::null(),
            MOVEFILE_DELAY_UNTIL_REBOOT,
        );
    }
}

/// Last-resort permission fix before giving up and scheduling a
/// delayed delete: grants the current user full control, recursively.
/// A pragmatic stand-in for the original's hand-rolled ACL/DACL reset (see
/// docs/RUST-REWRITE-SPEC.md §3.1) — `icacls` ships with every Windows
/// install, so this adds no dependency.
fn grant_full_control(path: &str) {
    let Ok(user) = std::env::var("USERNAME") else {
        return;
    };
    if user.is_empty() {
        return;
    }
    let _ = std::process::Command::new("icacls.exe")
        .args([path, "/grant", &format!("{user}:F"), "/t", "/c", "/q"])
        .output();
}

fn walk(dir: &Path, remaining_depth: u32, out: &mut Vec<String>) {
    if remaining_depth == 0 {
        return;
    }
    let Ok(entries) = fs::read_dir(dir) else {
        return;
    };
    for entry in entries.flatten() {
        let path = entry.path();
        if let Some(s) = path.to_str() {
            out.push(s.to_string());
        }
        if path.is_dir() {
            walk(&path, remaining_depth - 1, out);
        }
    }
}

fn clear_attributes_recursive(dir: &Path) {
    if let Some(s) = dir.to_str() {
        clear_attributes(s);
    }
    let Ok(entries) = fs::read_dir(dir) else {
        return;
    };
    for entry in entries.flatten() {
        let path = entry.path();
        if let Some(s) = path.to_str() {
            clear_attributes(s);
        }
        if path.is_dir() {
            clear_attributes_recursive(&path);
        }
    }
}

fn schedule_delete_tree_on_reboot(dir: &Path) {
    if let Ok(entries) = fs::read_dir(dir) {
        for entry in entries.flatten() {
            let path = entry.path();
            if path.is_dir() {
                schedule_delete_tree_on_reboot(&path);
            } else if let Some(s) = path.to_str() {
                schedule_delete_on_reboot(s);
            }
        }
    }
    if let Some(s) = dir.to_str() {
        schedule_delete_on_reboot(s);
    }
}

pub struct WinFileSystem;

impl FileSystem for WinFileSystem {
    fn kind(&self, path: &str) -> Option<EntryKind> {
        let meta = fs::symlink_metadata(path).ok()?;
        Some(if meta.is_dir() {
            EntryKind::Folder
        } else {
            EntryKind::File
        })
    }

    fn list_dir(&self, path: &str, max_depth: u32) -> Vec<String> {
        let mut results = Vec::new();
        walk(Path::new(path), max_depth, &mut results);
        results
    }

    fn company_name(&self, path: &str) -> Option<String> {
        crate::version_info::read_company_name(path)
    }

    fn remove_file(&mut self, path: &str) -> Removal {
        if fs::symlink_metadata(path).is_err() {
            return Removal::NotFound;
        }
        if fs::remove_file(path).is_ok() {
            return Removal::Deleted;
        }
        clear_attributes(path);
        if fs::remove_file(path).is_ok() {
            return Removal::Deleted;
        }
        grant_full_control(path);
        if fs::remove_file(path).is_ok() {
            return Removal::Deleted;
        }
        schedule_delete_on_reboot(path);
        Removal::ScheduledOnReboot
    }

    fn remove_dir(&mut self, path: &str) -> Removal {
        if fs::symlink_metadata(path).is_err() {
            return Removal::NotFound;
        }
        if fs::remove_dir_all(path).is_ok() {
            return Removal::Deleted;
        }
        clear_attributes_recursive(Path::new(path));
        if fs::remove_dir_all(path).is_ok() {
            return Removal::Deleted;
        }
        grant_full_control(path);
        if fs::remove_dir_all(path).is_ok() {
            return Removal::Deleted;
        }
        schedule_delete_tree_on_reboot(Path::new(path));
        Removal::ScheduledOnReboot
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn temp_dir(name: &str) -> std::path::PathBuf {
        let dir = std::env::temp_dir().join(format!("kprm-fs-test-{name}-{}", std::process::id()));
        fs::create_dir_all(&dir).unwrap();
        dir
    }

    #[test]
    fn kind_reports_none_for_a_missing_path() {
        let fs_port = WinFileSystem;
        assert_eq!(fs_port.kind(r"C:\this\definitely\does\not\exist"), None);
    }

    #[test]
    fn kind_and_removal_round_trip_on_a_real_temp_file() {
        let dir = temp_dir("plain-file");
        let file = dir.join("victim.txt");
        fs::write(&file, b"hello").unwrap();
        let path = file.to_str().unwrap();

        let mut fs_port = WinFileSystem;
        assert_eq!(fs_port.kind(path), Some(EntryKind::File));
        assert_eq!(fs_port.remove_file(path), Removal::Deleted);
        assert_eq!(fs_port.kind(path), None);

        fs::remove_dir_all(&dir).ok();
    }

    #[test]
    fn removing_a_read_only_file_still_succeeds() {
        let dir = temp_dir("readonly-file");
        let file = dir.join("victim.txt");
        fs::write(&file, b"hello").unwrap();
        let mut perms = fs::metadata(&file).unwrap().permissions();
        perms.set_readonly(true);
        fs::set_permissions(&file, perms).unwrap();
        let path = file.to_str().unwrap();

        let mut fs_port = WinFileSystem;
        assert_eq!(fs_port.remove_file(path), Removal::Deleted);

        fs::remove_dir_all(&dir).ok();
    }

    #[test]
    fn remove_dir_deletes_a_real_temp_folder_with_contents() {
        let dir = temp_dir("folder-with-contents");
        fs::write(dir.join("a.txt"), b"a").unwrap();
        fs::create_dir(dir.join("sub")).unwrap();
        fs::write(dir.join("sub").join("b.txt"), b"b").unwrap();
        let path = dir.to_str().unwrap().to_string();

        let mut fs_port = WinFileSystem;
        assert_eq!(fs_port.kind(&path), Some(EntryKind::Folder));
        assert_eq!(fs_port.remove_dir(&path), Removal::Deleted);
        assert_eq!(fs_port.kind(&path), None);
    }

    #[test]
    fn list_dir_finds_nested_children_up_to_max_depth() {
        let dir = temp_dir("list-dir");
        fs::write(dir.join("top.txt"), b"x").unwrap();
        fs::create_dir(dir.join("sub")).unwrap();
        fs::write(dir.join("sub").join("nested.txt"), b"x").unwrap();

        let fs_port = WinFileSystem;
        let shallow = fs_port.list_dir(dir.to_str().unwrap(), 1);
        assert!(shallow.iter().any(|p| p.ends_with("top.txt")));
        assert!(!shallow.iter().any(|p| p.ends_with("nested.txt")));

        let deep = fs_port.list_dir(dir.to_str().unwrap(), 2);
        assert!(deep.iter().any(|p| p.ends_with("nested.txt")));

        fs::remove_dir_all(&dir).ok();
    }
}
