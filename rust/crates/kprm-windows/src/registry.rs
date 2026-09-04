//! Real registry access via the `winreg` crate, implementing
//! [`kprm_engine::ports::Registry`]. Understands the internal `HKLM64`/
//! `HKCU64` convention from [`kprm_engine::registry`] by mapping it to the
//! `KEY_WOW64_64KEY` access flag rather than a literal hive name.

use kprm_engine::ports::Registry;
use winreg::enums::*;
use winreg::RegKey;

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
}
