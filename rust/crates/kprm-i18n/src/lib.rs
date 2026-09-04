//! The 8 UI languages KpRm has shipped since its AutoIt days (FR/EN/DE/IT/
//! PT/RU/ES/NL), ported from the `Lang_XX()` functions in
//! `src/kp_includes/kp_languages.au3` to Fluent resources. See
//! docs/RUST-REWRITE-SPEC.md §6.
//!
//! Unlike the original — 8 near-identical AutoIt functions with no
//! guarantee they all define the same set of variables — this crate is
//! tested (`tests::every_locale_defines_the_same_keys`) to catch a missing
//! translation key at build/test time instead of at the moment a user's OS
//! language happens to hit it.

#[cfg(test)]
use std::collections::BTreeSet;

use fluent_bundle::{FluentBundle, FluentResource};
use include_dir::{include_dir, Dir};
use unic_langid::LanguageIdentifier;

static LOCALES_DIR: Dir<'_> = include_dir!("$CARGO_MANIFEST_DIR/locales");

/// Locale codes this crate ships a translation for, in the same order the
/// original `Select`/`Case` chain in `kp_languages.au3` checked them
/// (`@OSLang` regex on `..0C$`/`..10$`/... — see docs/RUST-REWRITE-SPEC.md
/// §3.10 for why we key by a plain language tag instead of that legacy
/// Windows LANGID convention now).
pub const SUPPORTED_LOCALES: &[&str] = &["fr", "it", "de", "es", "pt", "nl", "ru", "en"];

/// Default locale when the system locale doesn't match any supported one —
/// matches the original's `Case Else -> Lang_EN()`.
pub const DEFAULT_LOCALE: &str = "en";

#[derive(Debug, thiserror::Error)]
pub enum I18nError {
    #[error("locale '{0}' is not embedded in this build")]
    UnknownLocale(String),
    #[error("locale '{0}' is not a valid language tag: {1}")]
    InvalidLanguageTag(String, unic_langid::LanguageIdentifierError),
    #[error("locale '{locale}' failed to parse its Fluent resource: {errors:?}")]
    MalformedResource { locale: String, errors: Vec<String> },
    #[error("key '{0}' is missing from this locale")]
    MissingKey(String),
}

/// A loaded set of translated strings for one locale.
pub struct Translations {
    bundle: FluentBundle<FluentResource>,
}

impl Translations {
    /// Loads the translations for `locale` (must be one of
    /// [`SUPPORTED_LOCALES`]). Prefer [`Translations::for_system_locale`]
    /// when picking a locale from the user's environment, since it never
    /// fails (falling back to [`DEFAULT_LOCALE`] instead).
    pub fn load(locale: &str) -> Result<Self, I18nError> {
        let file = LOCALES_DIR
            .get_file(format!("{locale}.ftl"))
            .ok_or_else(|| I18nError::UnknownLocale(locale.to_string()))?;
        let source = file
            .contents_utf8()
            .expect("embedded .ftl resources are UTF-8 by construction");

        let resource = FluentResource::try_new(source.to_string()).map_err(|(_, errors)| {
            I18nError::MalformedResource {
                locale: locale.to_string(),
                errors: errors.iter().map(|e| e.to_string()).collect(),
            }
        })?;

        let langid: LanguageIdentifier = locale
            .parse()
            .map_err(|e| I18nError::InvalidLanguageTag(locale.to_string(), e))?;

        let mut bundle = FluentBundle::new(vec![langid]);
        bundle
            .add_resource(resource)
            .expect("each locale file is a single resource with no duplicate message ids");

        Ok(Translations { bundle })
    }

    /// Picks the best supported locale for `system_locale` (e.g. `"fr-FR"`,
    /// `"fr_CH"`, `"de-DE"`) by matching its leading language subtag, falling
    /// back to [`DEFAULT_LOCALE`] — this never fails.
    pub fn for_system_locale(system_locale: &str) -> Self {
        let code = resolve_locale(system_locale);
        Self::load(code).expect("resolve_locale only ever returns a supported, embedded locale")
    }

    /// Looks up `key` and formats it (no arguments — every KpRm UI string is
    /// a plain literal, ported as-is from the original `$lXxx` constants).
    pub fn get(&self, key: &str) -> Result<String, I18nError> {
        let message = self
            .bundle
            .get_message(key)
            .ok_or_else(|| I18nError::MissingKey(key.to_string()))?;
        let pattern = message
            .value()
            .ok_or_else(|| I18nError::MissingKey(key.to_string()))?;
        let mut errors = Vec::new();
        let value = self.bundle.format_pattern(pattern, None, &mut errors);
        Ok(value.into_owned())
    }
}

/// Matches a system locale string against [`SUPPORTED_LOCALES`] by leading
/// language subtag (`"fr-FR"` -> `"fr"`), defaulting to [`DEFAULT_LOCALE`].
pub fn resolve_locale(system_locale: &str) -> &'static str {
    let lower = system_locale.to_ascii_lowercase();
    let lang_subtag = lower.split(['-', '_']).next().unwrap_or(&lower);
    SUPPORTED_LOCALES
        .iter()
        .find(|&&code| code == lang_subtag)
        .copied()
        .unwrap_or(DEFAULT_LOCALE)
}

/// Message ids present in a locale's raw `.ftl` source. Parsed with a plain
/// line scan (rather than Fluent's AST) so this check stays independent of
/// `fluent-bundle`'s internal API surface: any top-level `key = value` line
/// is a message id, which is all this catalog's flat, argument-free
/// resources ever use.
#[cfg(test)]
fn message_ids(ftl_source: &str) -> BTreeSet<String> {
    ftl_source
        .lines()
        .filter(|line| !line.starts_with(' ') && !line.starts_with('#') && !line.trim().is_empty())
        .filter_map(|line| line.split_once('='))
        .map(|(id, _)| id.trim().to_string())
        .collect()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn every_supported_locale_has_an_embedded_resource() {
        for &locale in SUPPORTED_LOCALES {
            Translations::load(locale)
                .unwrap_or_else(|e| panic!("locale '{locale}' failed to load: {e}"));
        }
    }

    #[test]
    fn every_locale_defines_the_same_keys() {
        let mut reference: Option<(String, BTreeSet<String>)> = None;

        for &locale in SUPPORTED_LOCALES {
            let file = LOCALES_DIR.get_file(format!("{locale}.ftl")).unwrap();
            let ids = message_ids(file.contents_utf8().unwrap());
            assert!(!ids.is_empty(), "locale '{locale}' defines no keys at all");

            match &reference {
                None => reference = Some((locale.to_string(), ids)),
                Some((ref_locale, ref_ids)) => {
                    let missing: Vec<_> = ref_ids.difference(&ids).collect();
                    let extra: Vec<_> = ids.difference(ref_ids).collect();
                    assert!(
                        missing.is_empty() && extra.is_empty(),
                        "locale '{locale}' differs from '{ref_locale}': missing {missing:?}, extra {extra:?}"
                    );
                }
            }
        }
    }

    #[test]
    fn resolve_locale_matches_language_subtag_case_insensitively() {
        assert_eq!(resolve_locale("fr-FR"), "fr");
        assert_eq!(resolve_locale("fr_CH"), "fr");
        assert_eq!(resolve_locale("DE-de"), "de");
        assert_eq!(resolve_locale("ru-RU"), "ru");
    }

    #[test]
    fn resolve_locale_falls_back_to_english() {
        assert_eq!(resolve_locale("ja-JP"), "en");
        assert_eq!(resolve_locale(""), "en");
    }

    #[test]
    fn a_known_key_resolves_to_the_expected_french_text() {
        let fr = Translations::load("fr").unwrap();
        assert_eq!(fr.get("run").unwrap(), "Exécuter");
        assert_eq!(fr.get("no-tool").unwrap(), "Aucun outil trouvé");
    }

    #[test]
    fn a_known_key_resolves_to_the_expected_english_text() {
        let en = Translations::load("en").unwrap();
        assert_eq!(en.get("run").unwrap(), "Run");
    }

    #[test]
    fn missing_key_is_a_typed_error_not_a_panic() {
        let en = Translations::load("en").unwrap();
        assert!(matches!(
            en.get("this-key-does-not-exist"),
            Err(I18nError::MissingKey(_))
        ));
    }

    #[test]
    fn unknown_locale_is_a_typed_error() {
        assert!(matches!(
            Translations::load("xx"),
            Err(I18nError::UnknownLocale(_))
        ));
    }
}
