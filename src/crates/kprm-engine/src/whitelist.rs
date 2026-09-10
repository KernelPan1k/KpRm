//! Hard-coded false-positive guards, ported 1:1 from
//! `src/kp_includes/functions/utils.au3` (`IsFileInWhiteList`,
//! `IsProcessInWhiteList`). See docs/RUST-REWRITE-SPEC.md §2.9.
//!
//! These patterns are checked against the *full path* (files) or the raw
//! process name, exactly as the original AutoIt did — note that the file
//! patterns are not anchored with `^`, so they match anywhere in the path.

use regex::RegexSet;
use std::sync::LazyLock;

const FILE_WHITELIST_PATTERNS: &[&str] = &[
    r"(?i)MKVPlayerSetup.*\.exe$",
    r"(?i)MKVExtractGUI.*\.exe$",
    r"(?i)mkvpropedit.*\.exe$",
    r"(?i)mkvinfo.*\.exe$",
    r"(?i)mkvextract.*\.exe$",
    r"(?i)mkvmerge.*\.exe$",
    r"(?i)mkvtoolnix.*\.exe$",
    r"(?i)MkvToMp4.*\.exe$",
];

const PROCESS_WHITELIST_PATTERNS: &[&str] = &[
    r"(?i)^sftvsa.exe$",
    r"(?i)^sftlist.exe$",
    r"(?i)^SftService.exe$",
];

static FILE_WHITELIST: LazyLock<RegexSet> = LazyLock::new(|| {
    RegexSet::new(FILE_WHITELIST_PATTERNS).expect("whitelist patterns are static and valid")
});

static PROCESS_WHITELIST: LazyLock<RegexSet> = LazyLock::new(|| {
    RegexSet::new(PROCESS_WHITELIST_PATTERNS).expect("whitelist patterns are static and valid")
});

/// `true` if `path` must never be deleted, regardless of any tool rule
/// matching it (MKV Toolnix binaries, historically confused with malware
/// tools by over-broad patterns in the catalog).
pub fn is_file_whitelisted(path: &str) -> bool {
    FILE_WHITELIST.is_match(path)
}

/// `true` if `process_name` must never be closed/killed (SoftGrid/App-V
/// components, historically confused with an "Ads" removal tool's process
/// pattern).
pub fn is_process_whitelisted(process_name: &str) -> bool {
    PROCESS_WHITELIST.is_match(process_name)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn whitelists_mkv_toolnix_files() {
        assert!(is_file_whitelisted(r"C:\Users\bob\Desktop\mkvmerge-64.exe"));
        assert!(is_file_whitelisted(r"C:\Downloads\MKVToolNix-setup.exe"));
    }

    #[test]
    fn does_not_whitelist_unrelated_files() {
        assert!(!is_file_whitelisted(r"C:\Users\bob\Desktop\AdwCleaner.exe"));
    }

    #[test]
    fn whitelists_softgrid_processes() {
        assert!(is_process_whitelisted("sftvsa.exe"));
        assert!(is_process_whitelisted("SftService.exe"));
    }

    #[test]
    fn does_not_whitelist_unrelated_processes() {
        assert!(!is_process_whitelisted("ads.exe"));
    }
}
