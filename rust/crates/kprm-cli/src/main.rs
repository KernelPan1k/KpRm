//! Headless entry point for KpRm — today a thin shell over `kprm-catalog`
//! and `kprm-i18n` used to validate the embedded data at build/release time
//! and to preview translated strings; the removal engine (`kprm-engine`)
//! gets real Windows adapters wired in here in a later phase (see
//! docs/RUST-REWRITE-SPEC.md §11, phase 3 onward). Kept as a separate binary
//! from the future GUI so catalog/locale checks can run in CI without a
//! display.

use clap::{Parser, Subcommand};
use kprm_catalog::Catalog;

#[derive(Parser)]
#[command(name = "kprm-cli", version, about = "KpRm headless utilities")]
struct Cli {
    #[command(subcommand)]
    command: Command,
}

#[derive(Subcommand)]
enum Command {
    /// Catalog inspection and validation.
    Catalog {
        #[command(subcommand)]
        action: CatalogAction,
    },
    /// Print one translated string in one locale.
    Translate {
        /// One of: fr, en, de, it, pt, ru, es, nl
        locale: String,
        /// Message key, e.g. `run`, `no-tool`.
        key: String,
    },
    /// List the locales this build embeds.
    Locales,
}

#[derive(Subcommand)]
enum CatalogAction {
    /// Print tool/action counts.
    Stats,
    /// List every tool name, one per line.
    List,
    /// Re-run structural + regex validation and report any error.
    Validate,
}

fn main() -> std::process::ExitCode {
    let cli = Cli::parse();

    match cli.command {
        Command::Catalog { action } => run_catalog_command(action),
        Command::Translate { locale, key } => run_translate_command(&locale, &key),
        Command::Locales => {
            for locale in kprm_i18n::SUPPORTED_LOCALES {
                println!("{locale}");
            }
            std::process::ExitCode::SUCCESS
        }
    }
}

fn load_catalog_or_exit() -> Catalog {
    match Catalog::embedded() {
        Ok(catalog) => catalog,
        Err(errors) => {
            eprintln!("catalog failed to load ({} error(s)):", errors.len());
            for e in errors {
                eprintln!("  - {e}");
            }
            std::process::exit(1);
        }
    }
}

fn run_catalog_command(action: CatalogAction) -> std::process::ExitCode {
    match action {
        CatalogAction::Stats => {
            let catalog = load_catalog_or_exit();
            println!("tools:   {}", catalog.tool_count());
            println!("actions: {}", catalog.action_count());
            std::process::ExitCode::SUCCESS
        }
        CatalogAction::List => {
            let catalog = load_catalog_or_exit();
            let mut names: Vec<&str> = catalog.tools().iter().map(|t| t.name.as_str()).collect();
            names.sort_unstable();
            for name in names {
                println!("{name}");
            }
            std::process::ExitCode::SUCCESS
        }
        CatalogAction::Validate => {
            let catalog = load_catalog_or_exit();
            let errors = catalog.validate();
            if errors.is_empty() {
                println!(
                    "OK — {} tools, {} actions, no errors",
                    catalog.tool_count(),
                    catalog.action_count()
                );
                std::process::ExitCode::SUCCESS
            } else {
                for e in &errors {
                    eprintln!("  - {e}");
                }
                eprintln!("{} error(s)", errors.len());
                std::process::ExitCode::FAILURE
            }
        }
    }
}

fn run_translate_command(locale: &str, key: &str) -> std::process::ExitCode {
    match kprm_i18n::Translations::load(locale) {
        Ok(translations) => match translations.get(key) {
            Ok(text) => {
                println!("{text}");
                std::process::ExitCode::SUCCESS
            }
            Err(e) => {
                eprintln!("{e}");
                std::process::ExitCode::FAILURE
            }
        },
        Err(e) => {
            eprintln!("{e}");
            std::process::ExitCode::FAILURE
        }
    }
}
