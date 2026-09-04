//! Resolution of the `@Macro`-prefixed paths used in the catalog (e.g.
//! `@AppDataCommonDir\ADiag\quarantine`), ported from `FormatPathWithMacro`
//! in `src/kp_includes/functions/utils.au3`. See docs/RUST-REWRITE-SPEC.md
//! §2.10.
//!
//! Kept independent of any real Windows API so it can be unit-tested with a
//! fake set of directories; `kprm-windows` provides the real
//! `SHGetKnownFolderPath`-backed implementation.

/// The known-folder paths a catalog `path = "..."` value may reference.
/// All values are plain strings (not `PathBuf`) to keep this module
/// trivially testable without touching the filesystem.
pub trait KnownDirs {
    fn app_data_common(&self) -> &str;
    fn desktop(&self) -> &str;
    fn local_app_data(&self) -> &str;
    fn home_drive(&self) -> &str;
    fn temp_dir(&self) -> &str;
    fn user_profile(&self) -> &str;

    /// Roaming `%APPDATA%` — not one of `FormatPathWithMacro`'s six original
    /// macros (no catalog `path=` value ever needed it), but required as a
    /// directory-walk root for the `app_data`/`user_start_menu` action types
    /// (see [`crate::orchestrator`]).
    fn app_data(&self) -> &str;
    /// The all-users Desktop (`desktop_common` action type's walk root).
    fn desktop_common(&self) -> &str;
    /// `%WINDIR%` (the `windows_folder` action type's walk root).
    fn windows_dir(&self) -> &str;
}

/// A macro's resolver function: given the known directories, returns the
/// path it stands for.
type MacroResolver = fn(&dyn KnownDirs) -> &str;

/// The macro prefixes recognized in the catalog, in the exact order the
/// original `Select`/`Case` chain checked them.
const MACROS: &[(&str, MacroResolver)] = &[
    ("@AppDataCommonDir", |d| d.app_data_common()),
    ("@DesktopDir", |d| d.desktop()),
    ("@LocalAppDataDir", |d| d.local_app_data()),
    ("@HomeDrive", |d| d.home_drive()),
    ("@TempDir", |d| d.temp_dir()),
    ("@UserProfileDir", |d| d.user_profile()),
];

/// Resolves a leading `@Macro` in `raw` against `dirs`, leaving the rest of
/// the string untouched. A path with no recognized macro prefix is returned
/// as-is (this matches the original: no macro found means the path is
/// already absolute).
pub fn resolve_path_macro(raw: &str, dirs: &dyn KnownDirs) -> String {
    for (macro_name, resolve) in MACROS {
        if let Some(rest) = raw.strip_prefix(macro_name) {
            return format!("{}{}", resolve(dirs), rest);
        }
    }
    raw.to_string()
}

#[cfg(test)]
mod tests {
    use super::*;

    struct FakeDirs;
    impl KnownDirs for FakeDirs {
        fn app_data_common(&self) -> &str {
            r"C:\ProgramData"
        }
        fn desktop(&self) -> &str {
            r"C:\Users\bob\Desktop"
        }
        fn local_app_data(&self) -> &str {
            r"C:\Users\bob\AppData\Local"
        }
        fn home_drive(&self) -> &str {
            "C:"
        }
        fn temp_dir(&self) -> &str {
            r"C:\Users\bob\AppData\Local\Temp"
        }
        fn user_profile(&self) -> &str {
            r"C:\Users\bob"
        }
        fn app_data(&self) -> &str {
            r"C:\Users\bob\AppData\Roaming"
        }
        fn desktop_common(&self) -> &str {
            r"C:\Users\Public\Desktop"
        }
        fn windows_dir(&self) -> &str {
            r"C:\Windows"
        }
    }

    #[test]
    fn resolves_each_known_macro() {
        let dirs = FakeDirs;
        assert_eq!(
            resolve_path_macro(r"@AppDataCommonDir\ADiag\quarantine", &dirs),
            r"C:\ProgramData\ADiag\quarantine"
        );
        assert_eq!(
            resolve_path_macro(r"@DesktopDir\cryptosearch-definitions.bin", &dirs),
            r"C:\Users\bob\Desktop\cryptosearch-definitions.bin"
        );
        assert_eq!(
            resolve_path_macro(r"@HomeDrive\Quarantine\Stinger", &dirs),
            r"C:\Quarantine\Stinger"
        );
    }

    #[test]
    fn leaves_absolute_paths_without_a_macro_untouched() {
        let dirs = FakeDirs;
        assert_eq!(
            resolve_path_macro(r"C:\Windows\System32\drivers\etc\hosts", &dirs),
            r"C:\Windows\System32\drivers\etc\hosts"
        );
    }
}
