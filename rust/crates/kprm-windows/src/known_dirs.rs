//! Real known-folder resolution via environment variables, implementing
//! [`kprm_engine::paths::KnownDirs`]. Env vars are a deliberate
//! simplification over `SHGetKnownFolderPath` (see
//! docs/RUST-REWRITE-SPEC.md §3.10) — correct for the vast majority of
//! machines, wrong only when a folder has been manually relocated via the
//! registry, a case the original AutoIt macros didn't handle specially
//! either (they're plain `@Macro` env-backed constants too).

use kprm_engine::paths::KnownDirs;

fn env_or(name: &str, fallback: &str) -> String {
    std::env::var(name).unwrap_or_else(|_| fallback.to_string())
}

pub struct EnvKnownDirs {
    app_data_common: String,
    desktop: String,
    local_app_data: String,
    home_drive: String,
    temp_dir: String,
    user_profile: String,
    app_data: String,
    desktop_common: String,
    windows_dir: String,
}

impl EnvKnownDirs {
    pub fn detect() -> Self {
        let user_profile = env_or("USERPROFILE", r"C:\Users\Default");
        Self {
            app_data_common: env_or("ProgramData", r"C:\ProgramData"),
            desktop: format!("{user_profile}\\Desktop"),
            local_app_data: env_or("LOCALAPPDATA", &format!("{user_profile}\\AppData\\Local")),
            home_drive: env_or("HOMEDRIVE", "C:"),
            temp_dir: env_or("TEMP", &format!("{user_profile}\\AppData\\Local\\Temp")),
            app_data: env_or("APPDATA", &format!("{user_profile}\\AppData\\Roaming")),
            desktop_common: format!("{}\\Desktop", env_or("PUBLIC", r"C:\Users\Public")),
            windows_dir: env_or("SystemRoot", r"C:\Windows"),
            user_profile,
        }
    }
}

impl KnownDirs for EnvKnownDirs {
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

/// `true` on a 64-bit Windows install, regardless of whether this process
/// itself is 32- or 64-bit — mirrors the original's `@OSArch = "X64"` check,
/// via the same env-var trick Windows itself uses under WOW64
/// (`PROCESSOR_ARCHITEW6432` is set only when a 32-bit process runs on a
/// 64-bit OS; `PROCESSOR_ARCHITECTURE` already says `AMD64`/`ARM64` for a
/// native 64-bit process).
pub fn is_64bit_os() -> bool {
    let native = std::env::var("PROCESSOR_ARCHITECTURE").unwrap_or_default();
    let wow64 = std::env::var("PROCESSOR_ARCHITEW6432").unwrap_or_default();
    let is_64 = |v: &str| v.eq_ignore_ascii_case("AMD64") || v.eq_ignore_ascii_case("ARM64");
    is_64(&native) || is_64(&wow64)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn detects_real_known_dirs_on_this_machine() {
        let dirs = EnvKnownDirs::detect();
        assert!(dirs.user_profile().len() > 2);
        assert!(dirs.desktop().ends_with("\\Desktop"));
        assert!(dirs.windows_dir().len() > 2);
    }

    #[test]
    fn this_dev_machine_is_64bit() {
        // Sanity check for the environment this crate was developed on —
        // not a hard requirement of the function itself.
        assert!(is_64bit_os());
    }
}
