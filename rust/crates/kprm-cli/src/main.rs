//! Headless entry point for KpRm. Two families of commands:
//! - `catalog`/`translate`/`locales`: inspect the embedded data, no I/O.
//! - `scan`/`remove`: run the real removal engine (`kprm-windows` adapters)
//!   against this machine. `scan` never touches anything (search-only);
//!   `remove` performs real deletions and requires `--confirm`.
//!
//! The GUI (`kprm-gui`, not built yet) will be a second front-end over the
//! same `kprm_engine::orchestrator` call.

use clap::{Parser, Subcommand, ValueEnum};
use kprm_catalog::Catalog;
use kprm_engine::orchestrator::{self, RunOptions};
use kprm_engine::quarantine::QuarantineMode;
use kprm_engine::report::{EventResult, Report};

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
    Translate { locale: String, key: String },
    /// List the locales this build embeds.
    Locales,
    /// Scan this machine for known tools — read-only, deletes nothing.
    Scan {
        #[arg(long, value_enum, default_value = "keep")]
        quarantine: QuarantineArg,
    },
    /// Remove every tool found by the catalog for real. Destructive.
    Remove {
        #[arg(long, value_enum, default_value = "keep")]
        quarantine: QuarantineArg,
        /// Required acknowledgement that this performs real deletions.
        #[arg(long)]
        confirm: bool,
    },
}

#[derive(Subcommand)]
enum CatalogAction {
    Stats,
    List,
    Validate,
}

#[derive(Clone, Copy, ValueEnum)]
enum QuarantineArg {
    Keep,
    Now,
    Sevendays,
}

impl From<QuarantineArg> for QuarantineMode {
    fn from(value: QuarantineArg) -> Self {
        match value {
            QuarantineArg::Keep => QuarantineMode::Keep,
            QuarantineArg::Now => QuarantineMode::Now,
            QuarantineArg::Sevendays => QuarantineMode::In7Days,
        }
    }
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
        Command::Scan { quarantine } => run_engine(quarantine.into(), true, false),
        Command::Remove {
            quarantine,
            confirm,
        } => {
            if !confirm {
                eprintln!(
                    "Refusing to run: this performs real deletions on this machine.\n\
                     Re-run with --confirm once you're sure."
                );
                return std::process::ExitCode::FAILURE;
            }
            run_engine(quarantine.into(), false, true)
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

fn run_engine(
    quarantine_mode: QuarantineMode,
    search_only: bool,
    destructive: bool,
) -> std::process::ExitCode {
    if destructive {
        println!("!! Running for real — this WILL delete files/registry keys/processes on this machine. !!");
    }

    let catalog = load_catalog_or_exit();
    let dirs = kprm_windows::EnvKnownDirs::detect();
    let mut fs = kprm_windows::WinFileSystem;
    let mut registry = kprm_windows::WinRegistry;
    let mut processes = kprm_windows::WinProcessManager;
    let mut commands = kprm_windows::RealCommandRunner;

    let options = RunOptions {
        quarantine_mode,
        search_only,
        is_64bit_os: kprm_windows::is_64bit_os(),
    };

    let report = orchestrator::run_tool_actions(
        &catalog,
        &mut fs,
        &mut registry,
        &mut processes,
        &mut commands,
        &dirs,
        &options,
    );

    print_report(&report);

    if destructive {
        let mut title = vec![format!(
            "# KpRm v{} — rapport du {}",
            env!("CARGO_PKG_VERSION"),
            kprm_windows::current_timestamp()
        )];
        title.extend(kprm_windows::collect_system_info(&dirs).to_lines());
        kprm_windows::write_and_open_report(&report, &dirs, &title);

        if report.needs_restart() {
            prompt_for_restart();
        }
    }

    std::process::ExitCode::SUCCESS
}

/// Some elements could only be scheduled for deletion on next boot
/// (`MOVEFILE_DELAY_UNTIL_REBOOT`) — ask before actually restarting the
/// machine, mirroring the original's `RestartIfNeeded`, but as an
/// explicit yes/no instead of an unconditional forced reboot.
fn prompt_for_restart() {
    use std::io::Write;

    println!();
    println!("- Redémarrage nécessaire -");
    println!("Certains éléments n'ont pu être supprimés qu'au prochain démarrage de Windows.");
    print!("Redémarrer maintenant ? [o/N] ");
    let _ = std::io::stdout().flush();

    let mut answer = String::new();
    if std::io::stdin().read_line(&mut answer).is_err() {
        return;
    }

    if matches!(
        answer.trim().to_lowercase().as_str(),
        "o" | "oui" | "y" | "yes"
    ) {
        if let Err(err) = kprm_windows::reboot_machine() {
            eprintln!("Échec du redémarrage : {err}");
        }
    } else {
        println!("Redémarrage reporté — pensez à redémarrer manuellement.");
    }
}

fn print_report(report: &Report) {
    if report.events.is_empty() {
        println!("Nothing found.");
        return;
    }

    for event in &report.events {
        let symbol = match event.result {
            EventResult::Removed | EventResult::Ran => "[OK]",
            EventResult::ScheduledOnReboot => "[R]",
            EventResult::Kept => "[KEEP]",
            EventResult::ScheduledIn7Days => "[7D]",
            EventResult::Found => "[?]",
            EventResult::Failed(_) => "[X]",
        };
        println!(
            "{symbol} {:<20} {:<16} {}",
            event.tool, event.action_type, event.target
        );
    }

    println!();
    println!("{} event(s) total.", report.events.len());
}
