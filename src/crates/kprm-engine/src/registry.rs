//! Registry key path helpers for the WOW64 32/64-bit view split, ported from
//! `GetSuffixKey`, `FormatForDisplayRegistryKey`, and `FormatForUseRegistryKey`
//! in `src/kp_includes/functions/utils.au3`.
//!
//! On 64-bit Windows, AutoIt's default (32-bit) registry view sees
//! `HKLM\SOFTWARE` redirected to `HKLM\SOFTWARE\WOW6432Node`; appending `64`
//! to the hive name (`HKLM64`, a convention internal to this codebase, not a
//! real hive) is how the original script asked for the native 64-bit view
//! instead. This module keeps that convention so catalog entries and reports
//! stay byte-for-byte comparable with the original tool's log output.

/// `"64"` on a 64-bit OS, `""` otherwise — appended to a hive name (`HKLM`,
/// `HKCU`) to request the native 64-bit registry view.
pub fn suffix_key(is_64bit_os: bool) -> &'static str {
    if is_64bit_os {
        "64"
    } else {
        ""
    }
}

/// Strips the internal `64` suffix from a hive name for display in reports,
/// so a user never sees the non-standard `HKLM64\...` spelling.
pub fn format_for_display(key: &str) -> String {
    for hive in ["HKLM", "HKCU", "HKU", "HKCR", "HKCC"] {
        let with_suffix = format!("{hive}64");
        if let Some(rest) = key.strip_prefix(&with_suffix) {
            return format!("{hive}{rest}");
        }
    }
    key.to_string()
}

/// Appends the internal `64` suffix to a plain `HKLM\...`/`HKCU\...` key so
/// it targets the native 64-bit view on a 64-bit OS. A key that already
/// carries the suffix, or that isn't a recognized hive root, is returned
/// unchanged.
pub fn format_for_use(key: &str, is_64bit_os: bool) -> String {
    if !is_64bit_os {
        return key.to_string();
    }
    for hive in ["HKLM", "HKCU", "HKU", "HKCR", "HKCC"] {
        if let Some(rest) = key.strip_prefix(hive) {
            if rest.starts_with('\\') || rest.is_empty() {
                return format!("{hive}64{rest}");
            }
        }
    }
    key.to_string()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn suffix_key_depends_on_os_bitness() {
        assert_eq!(suffix_key(true), "64");
        assert_eq!(suffix_key(false), "");
    }

    #[test]
    fn format_for_use_appends_suffix_on_64bit_os() {
        assert_eq!(
            format_for_use(r"HKLM\SOFTWARE\Foo", true),
            r"HKLM64\SOFTWARE\Foo"
        );
    }

    #[test]
    fn format_for_use_is_noop_on_32bit_os() {
        assert_eq!(
            format_for_use(r"HKLM\SOFTWARE\Foo", false),
            r"HKLM\SOFTWARE\Foo"
        );
    }

    #[test]
    fn format_for_display_strips_internal_suffix() {
        assert_eq!(
            format_for_display(r"HKLM64\SOFTWARE\Foo"),
            r"HKLM\SOFTWARE\Foo"
        );
        assert_eq!(
            format_for_display(r"HKCU\SOFTWARE\Foo"),
            r"HKCU\SOFTWARE\Foo"
        );
    }

    #[test]
    fn roundtrips_through_use_then_display() {
        let original = r"HKLM\SOFTWARE\Foo";
        let used = format_for_use(original, true);
        assert_eq!(format_for_display(&used), original);
    }
}
