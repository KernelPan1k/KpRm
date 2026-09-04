//! Restoring Windows' default UAC policy values, ported from `RestoreUAC`
//! in `src/kp_includes/functions/uac.au3`. See
//! docs/RUST-REWRITE-SPEC.md §2.13.
//!
//! Expressed purely over [`crate::ports::Registry`] so it never has to touch
//! a real `HKEY_LOCAL_MACHINE` in tests — writing these values for real on a
//! dev machine would change its actual security policy, which is exactly
//! the kind of side effect this abstraction exists to keep out of a test
//! suite.

use crate::ports::Registry;
use crate::registry::suffix_key;

const POLICY_KEY: &str = r"Software\Microsoft\Windows\CurrentVersion\Policies\System";

/// The 10 values and their Windows defaults, in the order the original
/// logged them.
const DEFAULTS: &[(&str, u32)] = &[
    ("EnableLUA", 1),
    ("ConsentPromptBehaviorAdmin", 5),
    ("ConsentPromptBehaviorUser", 3),
    ("EnableInstallerDetection", 0),
    ("EnableSecureUIAPaths", 1),
    ("EnableUIADesktopToggle", 0),
    ("EnableVirtualization", 1),
    ("FilterAdministratorToken", 0),
    ("PromptOnSecureDesktop", 1),
    ("ValidateAdminCodeSignatures", 0),
];

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct UacRestoreResult {
    pub value_name: &'static str,
    pub value: u32,
    pub succeeded: bool,
}

/// Writes every default value under `HKLM[64]\...\Policies\System`,
/// returning one result per value so a caller can log successes/failures
/// exactly like the original did (`[OK]`/`[X]` per line).
pub fn restore_uac(registry: &mut dyn Registry, is_64bit_os: bool) -> Vec<UacRestoreResult> {
    let key = format!(r"HKLM{}\{POLICY_KEY}", suffix_key(is_64bit_os));
    DEFAULTS
        .iter()
        .map(|&(name, value)| UacRestoreResult {
            value_name: name,
            value,
            succeeded: registry.write_dword(&key, name, value),
        })
        .collect()
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::fakes::FakeRegistry;

    #[test]
    fn writes_all_ten_default_values_under_the_64bit_key() {
        let mut registry = FakeRegistry::new();
        let results = restore_uac(&mut registry, true);

        assert_eq!(results.len(), 10);
        assert!(results.iter().all(|r| r.succeeded));
        assert_eq!(
            registry.written_dwords[0],
            (
                r"HKLM64\Software\Microsoft\Windows\CurrentVersion\Policies\System".to_string(),
                "EnableLUA".to_string(),
                1
            )
        );
    }

    #[test]
    fn uses_the_plain_key_on_a_32bit_os() {
        let mut registry = FakeRegistry::new();
        restore_uac(&mut registry, false);

        assert_eq!(
            registry.written_dwords[0].0,
            r"HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System"
        );
    }
}
