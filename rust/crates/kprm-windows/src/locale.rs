//! Detecting the user's OS UI language, for auto-selecting a `kprm-i18n`
//! locale — the real counterpart of the original's `@OSLang` check
//! (`kp_languages.au3`'s `Select`/`Case` chain over legacy Windows LANGID
//! codes). `GetUserDefaultLocaleName` returns a real BCP-47 tag directly
//! (e.g. `"fr-FR"`), which `kprm_i18n::resolve_locale` already knows how
//! to match by leading language subtag — no LANGID mapping table needed.

use windows::Win32::Globalization::GetUserDefaultLocaleName;

/// The current user's OS locale name (e.g. `"fr-FR"`, `"de-DE"`), or an
/// empty string if it couldn't be read — `kprm_i18n::resolve_locale`
/// falls back to its default locale for an empty/unrecognized string.
pub fn user_locale_name() -> String {
    let mut buffer = [0u16; 85]; // LOCALE_NAME_MAX_LENGTH
    let len = unsafe { GetUserDefaultLocaleName(&mut buffer) };
    if len <= 0 {
        return String::new();
    }
    // `len` counts the terminating null Windows itself writes into the
    // buffer; excluded here since Rust strings aren't null-terminated.
    String::from_utf16_lossy(&buffer[..(len as usize - 1)])
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn returns_a_plausible_locale_name() {
        let locale = user_locale_name();
        assert!(!locale.is_empty());
        assert!(locale.len() >= 2);
    }
}
