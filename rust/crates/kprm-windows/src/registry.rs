//! Real registry access via the `winreg` crate, implementing
//! [`kprm_engine::ports::Registry`]. Understands the internal `HKLM64`/
//! `HKCU64` convention from [`kprm_engine::registry`] by mapping it to the
//! `KEY_WOW64_64KEY` access flag rather than a literal hive name.

use kprm_engine::ports::Registry;
use winreg::enums::*;
use winreg::RegKey;

use crate::privilege::enable_privilege;

fn split_hive(key: &str) -> Option<(winreg::HKEY, &str, u32)> {
    let (hive_part, rest) = key.split_once('\\').unwrap_or((key, ""));
    let (hive_name, wow64_flag) = match hive_part.strip_suffix("64") {
        Some(h) => (h, KEY_WOW64_64KEY),
        None => (hive_part, 0),
    };
    let hive = match hive_name {
        "HKLM" => HKEY_LOCAL_MACHINE,
        "HKCU" => HKEY_CURRENT_USER,
        "HKU" => HKEY_USERS,
        "HKCR" => HKEY_CLASSES_ROOT,
        "HKCC" => HKEY_CURRENT_CONFIG,
        _ => return None,
    };
    Some((hive, rest, wow64_flag))
}

fn open(key: &str, perms: u32) -> Option<RegKey> {
    let (hive, rest, wow64_flag) = split_hive(key)?;
    let root = RegKey::predef(hive);
    if rest.is_empty() {
        Some(root)
    } else {
        root.open_subkey_with_flags(rest, perms | wow64_flag).ok()
    }
}

fn split_parent_and_leaf(key: &str) -> Option<(&str, &str)> {
    key.rsplit_once('\\')
}

pub struct WinRegistry;

impl Registry for WinRegistry {
    fn enum_subkeys(&self, key: &str) -> Vec<String> {
        let Some(reg_key) = open(key, KEY_READ) else {
            return Vec::new();
        };
        reg_key
            .enum_keys()
            .filter_map(|r| r.ok())
            .map(|name| format!("{key}\\{name}"))
            .collect()
    }

    fn read_value(&self, key: &str, value_name: &str) -> Option<String> {
        open(key, KEY_READ)?.get_value(value_name).ok()
    }

    fn has_any_value(&self, key: &str) -> bool {
        let Some(reg_key) = open(key, KEY_READ) else {
            return false;
        };
        reg_key.enum_values().next().is_some()
    }

    fn delete_key(&mut self, key: &str) -> bool {
        let Some((parent, leaf)) = split_parent_and_leaf(key) else {
            return false;
        };
        let Some(parent_key) = open(parent, KEY_ALL_ACCESS) else {
            return false;
        };
        parent_key.delete_subkey_all(leaf).is_ok()
    }

    fn write_dword(&mut self, key: &str, value_name: &str, value: u32) -> bool {
        let Some((hive, rest, wow64_flag)) = split_hive(key) else {
            return false;
        };
        let root = RegKey::predef(hive);
        let opened = if rest.is_empty() {
            Ok((root, RegDisposition::REG_OPENED_EXISTING_KEY))
        } else {
            root.create_subkey_with_flags(rest, KEY_WRITE | wow64_flag)
        };
        match opened {
            Ok((k, _)) => k.set_value(value_name, &value).is_ok(),
            Err(_) => false,
        }
    }

    fn save_key_to_file(&mut self, key: &str, file_path: &str) -> bool {
        use windows::core::PCWSTR;
        use windows::Win32::Foundation::ERROR_SUCCESS;
        use windows::Win32::Security::SE_BACKUP_NAME;
        use windows::Win32::System::Registry::{RegSaveKeyExW, HKEY as WinHKEY, REG_LATEST_FORMAT};

        // Needed to read protected subtrees of e.g. HKLM\SOFTWARE in full;
        // a normal (even administrator) token doesn't hold it by default.
        let _ = enable_privilege(SE_BACKUP_NAME);

        let Some(reg_key) = open(key, KEY_READ) else {
            return false;
        };

        // RegSaveKeyExW fails outright if the destination file already
        // exists — this is meant to overwrite a previous backup attempt.
        let _ = std::fs::remove_file(file_path);

        let hkey = WinHKEY(reg_key.raw_handle() as *mut core::ffi::c_void);
        let wide_path: Vec<u16> = file_path.encode_utf16().chain(std::iter::once(0)).collect();

        let result =
            unsafe { RegSaveKeyExW(hkey, PCWSTR(wide_path.as_ptr()), None, REG_LATEST_FORMAT) };

        result == ERROR_SUCCESS
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    /// All tests operate under this private, self-cleaning subtree — never
    /// against a real application's keys — so a run always leaves the
    /// registry exactly as it found it.
    const TEST_ROOT: &str = r"HKCU\Software\KpRmRustTests";

    fn cleanup() {
        let hkcu = RegKey::predef(HKEY_CURRENT_USER);
        let _ = hkcu.delete_subkey_all(r"Software\KpRmRustTests");
    }

    #[test]
    fn write_dword_persists_a_real_dword_value() {
        cleanup();
        let mut registry = WinRegistry;
        let key = format!("{TEST_ROOT}\\Sub");

        assert!(registry.write_dword(&key, "TestValue", 42));
        assert!(registry.has_any_value(&key));

        // `read_value` is typed for the catalog's own use case (reading a
        // REG_SZ like `DisplayName`, see `search_registry_key`) — verify the
        // DWORD landed correctly by reading it back with its real type
        // instead, straight from `winreg`.
        let raw: u32 = open(&key, KEY_READ)
            .unwrap()
            .get_value("TestValue")
            .unwrap();
        assert_eq!(raw, 42);

        cleanup();
    }

    #[test]
    fn enum_subkeys_lists_real_children() {
        cleanup();
        let mut registry = WinRegistry;
        registry.write_dword(&format!("{TEST_ROOT}\\ChildA"), "V", 1);
        registry.write_dword(&format!("{TEST_ROOT}\\ChildB"), "V", 1);

        let children = registry.enum_subkeys(TEST_ROOT);
        assert!(children.contains(&format!("{TEST_ROOT}\\ChildA")));
        assert!(children.contains(&format!("{TEST_ROOT}\\ChildB")));

        cleanup();
    }

    #[test]
    fn delete_key_removes_it_for_real() {
        cleanup();
        let mut registry = WinRegistry;
        let key = format!("{TEST_ROOT}\\ToDelete");
        registry.write_dword(&key, "V", 1);
        assert!(registry.has_any_value(&key));

        assert!(registry.delete_key(&key));
        assert!(!registry.has_any_value(&key));

        cleanup();
    }

    #[test]
    fn has_any_value_is_false_for_a_missing_key() {
        cleanup();
        let registry = WinRegistry;
        assert!(!registry.has_any_value(&format!("{TEST_ROOT}\\DoesNotExist")));
    }

    #[test]
    fn save_key_to_file_writes_a_real_hive_file() {
        // RegSaveKeyExW needs SeBackupPrivilege actually *held* by the
        // token, not just an administrator account — a standard (non-
        // elevated) token doesn't carry it at all, so AdjustTokenPrivileges
        // reports success while silently granting nothing. Skip rather
        // than fail when this test itself isn't running elevated.
        if !crate::elevation::is_elevated() {
            eprintln!("skipping: not elevated (RegSaveKeyExW needs SeBackupPrivilege)");
            return;
        }

        cleanup();
        let mut registry = WinRegistry;
        let key = format!("{TEST_ROOT}\\ToBackup");
        registry.write_dword(&key, "V", 7);

        let temp_dir = std::env::temp_dir().join(format!("kprm-test-hive-{}", std::process::id()));
        std::fs::create_dir_all(&temp_dir).unwrap();
        let file_path = temp_dir.join("backup.hiv");

        let succeeded = registry.save_key_to_file(&key, file_path.to_str().unwrap());
        let bytes = std::fs::read(&file_path).unwrap_or_default();

        std::fs::remove_dir_all(&temp_dir).ok();
        cleanup();

        assert!(succeeded);
        assert!(bytes.len() > 4);
        assert_eq!(
            &bytes[0..4],
            b"regf",
            "missing registry hive file magic header"
        );
    }
}
