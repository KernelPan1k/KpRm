//! Deciding which tool rule(s) apply to one filesystem entry, ported from
//! `RemoveFileHandler`/`RemoveFile`/`RemoveFolder`
//! (`src/kp_includes/functions/remove.au3`). See
//! docs/RUST-REWRITE-SPEC.md §2.6 and §4.3.
//!
//! This module is deliberately independent of any real directory walk: it
//! takes one already-discovered [`CandidateEntry`] and a list of
//! [`FileRule`]s and decides which ones fire. A `kprm-windows` adapter is
//! responsible for producing the candidates (via `FindFirstFile`/
//! `FindNextFile` walks) and calling this for each one — kept separate so
//! the matching semantics themselves (whitelist, company-name filter,
//! multiple tools matching the same entry) are unit-testable without a real
//! filesystem.

use kprm_catalog::EntryKind;
use regex::Regex;

use crate::whitelist::is_file_whitelisted;

/// One filesystem entry found while walking a directory the catalog cares
/// about (Desktop, Downloads, Program Files, ...).
pub struct CandidateEntry<'a> {
    /// Full path, used for the whitelist check and for reporting.
    pub full_path: &'a str,
    /// Just the file/folder name, matched against each rule's `pattern`.
    pub file_name: &'a str,
    pub kind: EntryKind,
    /// `CompanyName` version-resource field, read lazily by the caller only
    /// when at least one candidate rule requires it (reading a PE's version
    /// info is comparatively expensive) — `None` if not read/available.
    pub company_name: Option<&'a str>,
}

/// One rule from the catalog, narrowed down to what the matcher needs
/// (already-compiled regexes, resolved to a single tool).
pub struct FileRule<'a> {
    pub tool: &'a str,
    pub pattern: &'a Regex,
    /// `None` means "no company filter" (the catalog's `company_name = ""`).
    pub company_name: Option<&'a Regex>,
    pub kind: EntryKind,
    pub quarantine: bool,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Match<'a> {
    pub tool: &'a str,
    pub quarantine: bool,
}

pub(crate) fn has_exe_or_com_extension(file_name: &str) -> bool {
    let lower = file_name.to_ascii_lowercase();
    lower.ends_with(".exe") || lower.ends_with(".com")
}

/// Returns every rule that fires for `entry`, in `rules` order. Unlike a
/// typical "first match wins" matcher, **all** matching rules fire — two
/// different tools whose patterns both match the same file each get their
/// own [`Match`], exactly like the original `RemoveFileHandler`'s
/// non-breaking loop (see docs/RUST-REWRITE-SPEC.md §4.3 on rule overlap).
pub fn match_entry<'a>(entry: &CandidateEntry, rules: &'a [FileRule<'a>]) -> Vec<Match<'a>> {
    // The whitelist only ever protects files (folders have no equivalent
    // check in the original engine — `RemoveFolder` never consults it).
    if entry.kind == EntryKind::File && is_file_whitelisted(entry.full_path) {
        return Vec::new();
    }

    let mut matches = Vec::new();

    for rule in rules {
        if rule.kind != entry.kind {
            continue;
        }
        if !rule.pattern.is_match(entry.file_name) {
            continue;
        }

        // The company-name filter only ever applies to files, and only to
        // `.exe`/`.com` files at that (RemoveFile in remove.au3): a matching
        // `.txt`/`.zip`/... file, or any folder, is never rejected on this
        // basis even if the rule specifies a company_name.
        if let Some(company_pattern) = rule.company_name {
            if entry.kind == EntryKind::File && has_exe_or_com_extension(entry.file_name) {
                let passes = entry
                    .company_name
                    .is_some_and(|actual| company_pattern.is_match(actual));
                if !passes {
                    continue;
                }
            }
        }

        matches.push(Match {
            tool: rule.tool,
            quarantine: rule.quarantine,
        });
    }

    matches
}

#[cfg(test)]
mod tests {
    use super::*;

    fn rule<'a>(tool: &'a str, pattern: &'a Regex, kind: EntryKind) -> FileRule<'a> {
        FileRule {
            tool,
            pattern,
            company_name: None,
            kind,
            quarantine: false,
        }
    }

    #[test]
    fn matches_a_simple_pattern() {
        let pattern = Regex::new(r"(?i)^AdwCleaner.*\.exe$").unwrap();
        let rules = vec![rule("AdwCleaner", &pattern, EntryKind::File)];
        let entry = CandidateEntry {
            full_path: r"C:\Users\bob\Desktop\AdwCleaner.exe",
            file_name: "AdwCleaner.exe",
            kind: EntryKind::File,
            company_name: None,
        };
        let matches = match_entry(&entry, &rules);
        assert_eq!(
            matches,
            vec![Match {
                tool: "AdwCleaner",
                quarantine: false
            }]
        );
    }

    #[test]
    fn whitelisted_file_never_matches_even_with_a_matching_pattern() {
        // A deliberately over-broad pattern that would otherwise catch mkvmerge.exe.
        let pattern = Regex::new(r"(?i).*\.exe$").unwrap();
        let rules = vec![rule("SomeOverBroadTool", &pattern, EntryKind::File)];
        let entry = CandidateEntry {
            full_path: r"C:\Users\bob\Desktop\mkvmerge.exe",
            file_name: "mkvmerge.exe",
            kind: EntryKind::File,
            company_name: None,
        };
        assert!(match_entry(&entry, &rules).is_empty());
    }

    #[test]
    fn company_name_filter_rejects_mismatched_publisher() {
        let pattern = Regex::new(r"(?i)^AdwCleaner.*\.exe$").unwrap();
        let company = Regex::new(r"(?i)^Malwarebytes").unwrap();
        let rules = vec![FileRule {
            tool: "AdwCleaner",
            pattern: &pattern,
            company_name: Some(&company),
            kind: EntryKind::File,
            quarantine: false,
        }];
        let entry = CandidateEntry {
            full_path: r"C:\Users\bob\Desktop\AdwCleaner.exe",
            file_name: "AdwCleaner.exe",
            kind: EntryKind::File,
            company_name: Some("Some Other Vendor Inc."),
        };
        assert!(match_entry(&entry, &rules).is_empty());
    }

    #[test]
    fn company_name_filter_accepts_matching_publisher() {
        let pattern = Regex::new(r"(?i)^AdwCleaner.*\.exe$").unwrap();
        let company = Regex::new(r"(?i)^Malwarebytes").unwrap();
        let rules = vec![FileRule {
            tool: "AdwCleaner",
            pattern: &pattern,
            company_name: Some(&company),
            kind: EntryKind::File,
            quarantine: false,
        }];
        let entry = CandidateEntry {
            full_path: r"C:\Users\bob\Desktop\AdwCleaner.exe",
            file_name: "AdwCleaner.exe",
            kind: EntryKind::File,
            company_name: Some("Malwarebytes Inc."),
        };
        assert_eq!(
            match_entry(&entry, &rules),
            vec![Match {
                tool: "AdwCleaner",
                quarantine: false
            }]
        );
    }

    #[test]
    fn company_name_filter_is_skipped_for_non_exe_files() {
        // A .txt log matching a rule that carries a company_name filter must
        // not be rejected for lacking version info (only .exe/.com carry it).
        let pattern = Regex::new(r"(?i)^AdwCleaner.*\.txt$").unwrap();
        let company = Regex::new(r"(?i)^Malwarebytes").unwrap();
        let rules = vec![FileRule {
            tool: "AdwCleaner",
            pattern: &pattern,
            company_name: Some(&company),
            kind: EntryKind::File,
            quarantine: false,
        }];
        let entry = CandidateEntry {
            full_path: r"C:\Users\bob\Desktop\AdwCleaner_log.txt",
            file_name: "AdwCleaner_log.txt",
            kind: EntryKind::File,
            company_name: None,
        };
        assert_eq!(
            match_entry(&entry, &rules),
            vec![Match {
                tool: "AdwCleaner",
                quarantine: false
            }]
        );
    }

    #[test]
    fn folder_is_never_subject_to_the_company_name_filter() {
        let pattern = Regex::new(r"(?i)^AdwCleaner$").unwrap();
        let company = Regex::new(r"(?i)^Malwarebytes").unwrap();
        let rules = vec![FileRule {
            tool: "AdwCleaner",
            pattern: &pattern,
            company_name: Some(&company),
            kind: EntryKind::Folder,
            quarantine: true,
        }];
        let entry = CandidateEntry {
            full_path: r"C:\AdwCleaner",
            file_name: "AdwCleaner",
            kind: EntryKind::Folder,
            company_name: None,
        };
        assert_eq!(
            match_entry(&entry, &rules),
            vec![Match {
                tool: "AdwCleaner",
                quarantine: true
            }]
        );
    }

    #[test]
    fn two_tools_matching_the_same_entry_both_fire() {
        let pattern_a = Regex::new(r"(?i)^AdsFix").unwrap();
        let pattern_b = Regex::new(r"(?i)^Ads").unwrap();
        let rules = vec![
            rule("AdsFix", &pattern_a, EntryKind::File),
            rule("Ads", &pattern_b, EntryKind::File),
        ];
        let entry = CandidateEntry {
            full_path: r"C:\Users\bob\Desktop\AdsFix.exe",
            file_name: "AdsFix.exe",
            kind: EntryKind::File,
            company_name: None,
        };
        let matches = match_entry(&entry, &rules);
        assert_eq!(
            matches.len(),
            2,
            "both AdsFix and the broader Ads pattern should fire"
        );
    }

    #[test]
    fn kind_mismatch_never_matches() {
        let pattern = Regex::new(r"(?i)^AdwCleaner$").unwrap();
        let rules = vec![rule("AdwCleaner", &pattern, EntryKind::Folder)];
        let entry = CandidateEntry {
            full_path: r"C:\Users\bob\Desktop\AdwCleaner",
            file_name: "AdwCleaner",
            kind: EntryKind::File,
            company_name: None,
        };
        assert!(match_entry(&entry, &rules).is_empty());
    }
}
