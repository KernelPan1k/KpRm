//! Real collection of [`kprm_engine::system_info::SystemInfo`] — username,
//! computer name, OS name/build and run count, off the real machine.
//! Counterpart of the original's report header
//! (`src/kp_includes/functions/functions.au3` + `utils.au3`'s
//! `CountKpRmPass`).

use kprm_engine::paths::KnownDirs;
use kprm_engine::system_info::SystemInfo;
use winreg::enums::HKEY_LOCAL_MACHINE;
use winreg::RegKey;

use crate::known_dirs::{is_64bit_os, EnvKnownDirs};

/// `USERNAME`/`COMPUTERNAME` are standard Windows env vars (no API call
/// needed); the OS name/build come from the same registry key Windows
/// Explorer's "About" dialog reads, since there is no simpler public API
/// that reports the real Windows 11 name (`GetVersionEx` is deprecated and
/// lies about the version since Windows 8.1's manifest gating).
pub fn collect(dirs: &EnvKnownDirs) -> SystemInfo {
    let (os_name, os_build) = read_os_version();
    SystemInfo {
        username: std::env::var("USERNAME").unwrap_or_else(|_| "?".to_string()),
        computer_name: std::env::var("COMPUTERNAME").unwrap_or_else(|_| "?".to_string()),
        os_name,
        os_build,
        is_64bit: is_64bit_os(),
        pass_number: count_previous_passes(dirs.home_drive()),
    }
}

fn read_os_version() -> (String, String) {
    let key = match RegKey::predef(HKEY_LOCAL_MACHINE)
        .open_subkey(r"SOFTWARE\Microsoft\Windows NT\CurrentVersion")
    {
        Ok(key) => key,
        Err(_) => return ("Windows".to_string(), "?".to_string()),
    };

    let mut product_name: String = key
        .get_value("ProductName")
        .unwrap_or_else(|_| "Windows".to_string());
    let build_number: String = key
        .get_value("CurrentBuildNumber")
        .unwrap_or_else(|_| "?".to_string());
    let ubr: u32 = key.get_value("UBR").unwrap_or(0);

    // Registry ProductName still says "Windows 10 ..." on some Windows 11
    // installs — Microsoft never updated it, only the build number moved.
    if let Ok(build) = build_number.parse::<u32>() {
        if build >= 22000 && product_name.contains("Windows 10") {
            product_name = product_name.replacen("Windows 10", "Windows 11", 1);
        }
    }

    let os_build = if ubr > 0 {
        format!("{build_number}.{ubr}")
    } else {
        build_number
    };

    (product_name, os_build)
}

/// Counts existing `kprm-*.txt` reports in `<home_drive>\KPRM`, mirroring
/// the original's `CountKpRmPass` — how many times KpRm already ran on
/// this machine before this run.
fn count_previous_passes(home_drive: &str) -> usize {
    let kprm_dir = format!("{home_drive}\\KPRM");
    let Ok(entries) = std::fs::read_dir(&kprm_dir) else {
        return 0;
    };
    entries
        .filter_map(|entry| entry.ok())
        .filter(|entry| {
            entry
                .file_name()
                .to_str()
                .map(|name| name.starts_with("kprm-") && name.ends_with(".txt"))
                .unwrap_or(false)
        })
        .count()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn collects_plausible_values_on_this_machine() {
        let dirs = EnvKnownDirs::detect();
        let info = collect(&dirs);
        assert!(!info.username.is_empty());
        assert!(!info.computer_name.is_empty());
        assert!(info.os_name.starts_with("Windows"));
        assert!(!info.os_build.is_empty() && info.os_build != "?");
    }

    #[test]
    fn missing_directory_counts_as_zero() {
        assert_eq!(
            count_previous_passes(r"Z:\definitely-not-a-real-kprm-test-path"),
            0
        );
    }

    #[test]
    fn counts_only_matching_report_files() {
        let temp = std::env::temp_dir().join(format!("kprm-test-passes-{}", std::process::id()));
        let kprm_dir = temp.join("KPRM");
        std::fs::create_dir_all(&kprm_dir).unwrap();
        std::fs::write(kprm_dir.join("kprm-20260101-000000.txt"), "x").unwrap();
        std::fs::write(kprm_dir.join("kprm-20260102-000000.txt"), "x").unwrap();
        std::fs::write(kprm_dir.join("notes.txt"), "x").unwrap();

        let count = count_previous_passes(temp.to_str().unwrap());

        std::fs::remove_dir_all(&temp).ok();
        assert_eq!(count, 2);
    }
}
