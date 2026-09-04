//! In-memory fakes for the [`crate::ports`] traits, so
//! [`crate::orchestrator`] and any consumer crate can unit-test real
//! scenarios (a locked file, a matching registry key, a whitelisted
//! process...) without touching a real machine. See
//! docs/RUST-REWRITE-SPEC.md §9.0/§9.1.

use std::collections::{BTreeMap, BTreeSet};

use kprm_catalog::EntryKind;

use crate::paths::KnownDirs;
use crate::ports::{CommandRunner, FileSystem, ProcessInfo, ProcessManager, Registry, Removal};

#[derive(Debug, Clone)]
pub struct FakeEntry {
    pub kind: EntryKind,
    pub company_name: Option<String>,
    /// If `true`, the first removal attempt fails (simulates a locked
    /// file/folder) and the fake reports [`Removal::ScheduledOnReboot`].
    pub locked: bool,
}

/// An in-memory filesystem: a flat map of path -> entry, with children
/// tracked by string-prefix so [`FileSystem::list_dir`] works without a real
/// tree structure.
#[derive(Debug, Default)]
pub struct FakeFileSystem {
    entries: BTreeMap<String, FakeEntry>,
    pub removed: Vec<String>,
    pub scheduled_on_reboot: Vec<String>,
}

impl FakeFileSystem {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn add_file(&mut self, path: &str, company_name: Option<&str>) -> &mut Self {
        self.entries.insert(
            path.to_string(),
            FakeEntry {
                kind: EntryKind::File,
                company_name: company_name.map(str::to_string),
                locked: false,
            },
        );
        self
    }

    pub fn add_folder(&mut self, path: &str) -> &mut Self {
        self.entries.insert(
            path.to_string(),
            FakeEntry {
                kind: EntryKind::Folder,
                company_name: None,
                locked: false,
            },
        );
        self
    }

    pub fn lock(&mut self, path: &str) -> &mut Self {
        if let Some(e) = self.entries.get_mut(path) {
            e.locked = true;
        }
        self
    }
}

impl FileSystem for FakeFileSystem {
    fn kind(&self, path: &str) -> Option<EntryKind> {
        self.entries.get(path).map(|e| e.kind)
    }

    fn list_dir(&self, path: &str, _max_depth: u32) -> Vec<String> {
        let prefix = format!("{path}\\");
        self.entries
            .keys()
            .filter(|p| p.starts_with(&prefix))
            .cloned()
            .collect()
    }

    fn company_name(&self, path: &str) -> Option<String> {
        self.entries.get(path).and_then(|e| e.company_name.clone())
    }

    fn remove_file(&mut self, path: &str) -> Removal {
        remove_entry(self, path)
    }

    fn remove_dir(&mut self, path: &str) -> Removal {
        remove_entry(self, path)
    }
}

fn remove_entry(fs: &mut FakeFileSystem, path: &str) -> Removal {
    match fs.entries.get(path) {
        None => Removal::NotFound,
        Some(e) if e.locked => {
            fs.scheduled_on_reboot.push(path.to_string());
            Removal::ScheduledOnReboot
        }
        Some(_) => {
            fs.entries.remove(path);
            fs.removed.push(path.to_string());
            Removal::Deleted
        }
    }
}

/// An in-memory registry: keys are plain strings (e.g.
/// `"HKLM\\SOFTWARE\\Foo"`), values are `(name, content)` pairs.
#[derive(Debug, Default)]
pub struct FakeRegistry {
    keys: BTreeMap<String, BTreeMap<String, String>>,
    pub deleted_keys: Vec<String>,
    pub written_dwords: Vec<(String, String, u32)>,
}

impl FakeRegistry {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn add_key(&mut self, key: &str) -> &mut Self {
        self.keys.entry(key.to_string()).or_default();
        self
    }

    pub fn add_value(&mut self, key: &str, name: &str, value: &str) -> &mut Self {
        self.keys
            .entry(key.to_string())
            .or_default()
            .insert(name.to_string(), value.to_string());
        self
    }
}

impl Registry for FakeRegistry {
    fn enum_subkeys(&self, key: &str) -> Vec<String> {
        let prefix = format!("{key}\\");
        self.keys
            .keys()
            .filter_map(|k| k.strip_prefix(&prefix))
            .filter(|rest| !rest.contains('\\'))
            .map(|rest| format!("{key}\\{rest}"))
            .collect()
    }

    fn read_value(&self, key: &str, value_name: &str) -> Option<String> {
        self.keys.get(key).and_then(|v| v.get(value_name)).cloned()
    }

    fn has_any_value(&self, key: &str) -> bool {
        self.keys.get(key).is_some_and(|v| !v.is_empty())
    }

    fn delete_key(&mut self, key: &str) -> bool {
        let existed = self.keys.remove(key).is_some();
        if existed {
            self.deleted_keys.push(key.to_string());
        }
        existed
    }

    fn write_dword(&mut self, key: &str, value_name: &str, value: u32) -> bool {
        self.written_dwords
            .push((key.to_string(), value_name.to_string(), value));
        self.keys
            .entry(key.to_string())
            .or_default()
            .insert(value_name.to_string(), value.to_string());
        true
    }
}

#[derive(Debug, Default)]
pub struct FakeProcessManager {
    processes: Vec<ProcessInfo>,
    pub killed: BTreeSet<u32>,
}

impl FakeProcessManager {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn add(&mut self, pid: u32, name: &str, exe_path: Option<&str>) -> &mut Self {
        self.processes.push(ProcessInfo {
            pid,
            name: name.to_string(),
            exe_path: exe_path.map(str::to_string),
        });
        self
    }
}

impl ProcessManager for FakeProcessManager {
    fn list(&self) -> Vec<ProcessInfo> {
        self.processes.clone()
    }

    fn kill(&mut self, pid: u32) -> bool {
        self.processes.retain(|p| p.pid != pid);
        self.killed.insert(pid);
        true
    }
}

#[derive(Debug, Default)]
pub struct FakeCommandRunner {
    pub calls: Vec<(String, Vec<String>)>,
    pub always_succeeds: bool,
}

impl FakeCommandRunner {
    pub fn new() -> Self {
        Self {
            always_succeeds: true,
            ..Default::default()
        }
    }
}

impl CommandRunner for FakeCommandRunner {
    fn run(&mut self, program: &str, args: &[&str]) -> bool {
        self.calls.push((
            program.to_string(),
            args.iter().map(|s| s.to_string()).collect(),
        ));
        self.always_succeeds
    }
}

pub struct FakeKnownDirs {
    pub app_data_common: String,
    pub desktop: String,
    pub local_app_data: String,
    pub home_drive: String,
    pub temp_dir: String,
    pub user_profile: String,
    pub app_data: String,
    pub desktop_common: String,
    pub windows_dir: String,
}

impl Default for FakeKnownDirs {
    fn default() -> Self {
        Self {
            app_data_common: r"C:\ProgramData".to_string(),
            desktop: r"C:\Users\bob\Desktop".to_string(),
            local_app_data: r"C:\Users\bob\AppData\Local".to_string(),
            home_drive: "C:".to_string(),
            temp_dir: r"C:\Users\bob\AppData\Local\Temp".to_string(),
            user_profile: r"C:\Users\bob".to_string(),
            app_data: r"C:\Users\bob\AppData\Roaming".to_string(),
            desktop_common: r"C:\Users\Public\Desktop".to_string(),
            windows_dir: r"C:\Windows".to_string(),
        }
    }
}

impl KnownDirs for FakeKnownDirs {
    fn app_data_common(&self) -> &str {
        &self.app_data_common
    }
    fn desktop(&self) -> &str {
        &self.desktop
    }
    fn local_app_data(&self) -> &str {
        &self.local_app_data
    }
    fn home_drive(&self) -> &str {
        &self.home_drive
    }
    fn temp_dir(&self) -> &str {
        &self.temp_dir
    }
    fn user_profile(&self) -> &str {
        &self.user_profile
    }
    fn app_data(&self) -> &str {
        &self.app_data
    }
    fn desktop_common(&self) -> &str {
        &self.desktop_common
    }
    fn windows_dir(&self) -> &str {
        &self.windows_dir
    }
}
