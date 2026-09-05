//! Abstractions over real Windows I/O (filesystem, registry, processes,
//! external commands), so the removal orchestration in [`crate::orchestrator`]
//! is unit-testable with in-memory fakes and only `kprm-windows` needs to
//! touch a real machine. See docs/RUST-REWRITE-SPEC.md §5.1.

use kprm_catalog::EntryKind;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Removal {
    /// Deleted immediately.
    Deleted,
    /// Could not be deleted right now (locked); scheduled for deletion on
    /// next reboot (`MoveFileEx(..., MOVEFILE_DELAY_UNTIL_REBOOT)` on the
    /// real adapter).
    ScheduledOnReboot,
    /// Did not exist in the first place.
    NotFound,
}

pub trait FileSystem {
    /// `None` if `path` doesn't exist.
    fn kind(&self, path: &str) -> Option<EntryKind>;

    /// Immediate children of `path` (files and folders), as full paths.
    /// Real adapters walk up to `max_depth` levels deep (`1` = the
    /// directory's direct contents only); fakes may ignore depth.
    fn list_dir(&self, path: &str, max_depth: u32) -> Vec<String>;

    /// `CompanyName` version-resource field of a `.exe`/`.com`, if readable.
    fn company_name(&self, path: &str) -> Option<String>;

    fn remove_file(&mut self, path: &str) -> Removal;
    fn remove_dir(&mut self, path: &str) -> Removal;
}

pub trait Registry {
    fn enum_subkeys(&self, key: &str) -> Vec<String>;
    /// Reads a string-typed value (e.g. a `DisplayName`, as used by
    /// `search_registry_key`) — not meant for the DWORD values
    /// [`Registry::write_dword`] writes, which have their own real type.
    fn read_value(&self, key: &str, value_name: &str) -> Option<String>;
    /// `true` if the key exists and has at least one value (mirrors the
    /// original's `RegEnumVal(key, "1")` existence probe).
    fn has_any_value(&self, key: &str) -> bool;
    fn delete_key(&mut self, key: &str) -> bool;
    fn write_dword(&mut self, key: &str, value_name: &str, value: u32) -> bool;
}

#[derive(Debug, Clone)]
pub struct ProcessInfo {
    pub pid: u32,
    pub name: String,
    pub exe_path: Option<String>,
}

pub trait ProcessManager {
    fn list(&self) -> Vec<ProcessInfo>;
    fn kill(&mut self, pid: u32) -> bool;
}

/// Runs an external program to completion (`schtasks`, `netsh`, a tool's own
/// uninstaller, ...) and reports whether it exited successfully.
pub trait CommandRunner {
    fn run(&mut self, program: &str, args: &[&str]) -> bool;

    /// Like [`CommandRunner::run`], but returns the program's captured
    /// stdout on success instead of a bare bool — for the rare case where
    /// the caller needs the output (e.g. enumerating existing restore
    /// points via PowerShell). `None` on a non-zero exit or a program
    /// that couldn't even be launched.
    fn run_capture(&mut self, program: &str, args: &[&str]) -> Option<String>;
}
