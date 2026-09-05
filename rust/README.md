# KpRm

A free, open-source cleanup tool for Windows: it detects and removes
the third-party removal, diagnostic, and decryption tools a technician
typically runs (and forgets to clean up afterward) during a malware
removal session — AdwCleaner, FRST, the ESET/McAfee/Symantec/Kaspersky
one-off cleaners, ransomware decryptors, and more (202 tools known so
far). It also restores Windows defaults (UAC, system settings), manages
System Restore points, and backs up the registry before making changes.

This is a Rust rewrite of the original AutoIt3 KpRm by
[kernel-panik](https://kernel-panik.me/), rebuilt from scratch to
modernize the implementation while keeping the same behavior users
already know. See
[`../docs/RUST-REWRITE-SPEC.md`](../docs/RUST-REWRITE-SPEC.md) for the
full design rationale.

## Features

- Detects and removes 202 known cleanup/diagnostic/decryption tools
  (files, folders, registry keys, scheduled tasks, running processes —
  see the [full list](#supported-tools) below), killing any matching
  running process before deleting its files
- Three quarantine modes: keep flagged items in place, delete them
  immediately, or delete them after 7 days (a real Windows Scheduled
  Task performs the deferred deletion); picking "immediately" or "in 7
  days" automatically enables tool removal too
- Registry backup (`SOFTWARE` and `NTUSER.DAT` hives) before making
  changes
- System Restore point management: create one, or clear existing ones
- Restores UAC and a handful of system settings (network, DNS, Explorer
  display options) to their Windows defaults
- Writes a plain-text report after every real run, including machine
  info (username, computer name, OS build, how many times the tool has
  run on this machine before), plus a machine-readable JSON copy
  alongside it
- A numeric progress bar during a scan or a real run, instead of just a
  busy spinner
- Offers to restart the machine when a locked file could only be
  scheduled for deletion on next boot
- Deletes itself after a successful real run (matching the original's
  behavior — see the [Usage](#graphical-interface) note below)
- A GUI available in 8 languages (French, English, German, Italian,
  Portuguese, Russian, Spanish, Dutch), auto-selected from the Windows
  UI language
- A single-instance guard: launching a second copy while one is
  already running shows a message instead of opening twice
- A startup disclaimer/EULA screen, matching the original
- A single ~5 MB portable executable — no installer, no bundled
  runtime, no third-party DLL to ship alongside it
- Also usable headlessly from the command line, for scripting or
  automation

## Installation

Download `kprm.exe` and run it — nothing to install. It opens the GUI
when launched with no arguments, or runs headlessly when given a
[command-line subcommand](#command-line). Because almost everything it
does needs administrator rights (deleting files under `Program Files`,
writing to `HKEY_LOCAL_MACHINE`, managing System Restore, stopping
other users' processes...), it always requests UAC elevation on
launch — including for read-only subcommands, matching the original
tool's own always-elevated behavior.

## Usage

### Graphical interface

Launching `kprm.exe` with no arguments shows a disclaimer/EULA screen
first (matching the original's own startup warning), then opens the
GUI in the system's UI language (falling back to English if it isn't
one of the 8 embedded languages) with four tabs:

- **Automatique** ("Automatic"): a set of independent, individually
  optional actions, run together by the "Exécuter" ("Execute") button:
  - **Supprimer les outils** — remove every tool the catalog finds on
    this machine
  - **Sauvegarder le registre** — back up the `SOFTWARE` and
    `NTUSER.DAT` registry hives first
  - **Supprimer les points de restauration** — clear every existing
    System Restore point
  - **Créer un point de restauration** — create a fresh System Restore
    point
  - **Restaurer UAC** — reset User Account Control settings to their
    Windows defaults
  - **Restaurer les paramètres système** — reset network/DNS settings
    and a few Explorer display options to their Windows defaults
  - A quarantine mode selector (**Conserver** / **Maintenant** / **Dans
    7 jours**) controlling what happens to items the catalog flags for
    quarantine
- **Analyse personnalisée** ("Custom scan"): runs a read-only scan of
  the whole catalog, lists everything it found with a checkbox next to
  each item, and deletes only what you select
- **Outils +** ("Extra Tools"): restore a previous registry backup
  (created from a "Sauvegarder le registre" run) back over the live
  `SOFTWARE`/`NTUSER.DAT` hives — a new feature the original never had,
  see the note below
- **Dons** ("Donate"): a Bitcoin address for supporting the project, with a one-click copy button

(Tab and action names above are shown in French — the language this
project is developed in — but every label is translated; the screen
you actually see is in your Windows UI language if it's one of the 8
`kprm-i18n` embeds, English otherwise.)

> **Note on self-deletion**: matching the original tool's own
> behavior, `kprm.exe` deletes itself after a successful real run
> (`RunAutomatic`/`RemoveSelected` — not after a read-only scan). If a
> deletion had to be deferred to next boot, the self-deletion is folded
> into that same reboot instead of happening immediately. This means a
> release build used for manual testing needs to be rebuilt between
> runs; there's no flag to disable it, to stay faithful to the
> original.

> **Note on registry restore**: both `HKLM\SOFTWARE` and the current
> user's `NTUSER.DAT` are always open while Windows is running, so this
> can't call `RegRestoreKeyW` live against them — instead it schedules
> the backup file to replace the live hive file at next boot
> (`MOVEFILE_DELAY_UNTIL_REBOOT | MOVEFILE_REPLACE_EXISTING`, the same
> mechanism tools like ERUNT have used for decades). A restart is
> required for it to take effect, and — unlike every other destructive
> action in this app — it's gated behind an explicit "are you sure?"
> confirmation on top of the button click, since it overwrites live
> system state wholesale with no undo.

### Command line

Give `kprm.exe` a subcommand to run it headlessly instead of opening a
window:

```
kprm.exe <SUBCOMMAND> [OPTIONS]
```

| Subcommand | Description |
|---|---|
| `catalog stats` | Print the number of tools and actions in the embedded catalog. |
| `catalog list` | Print every tool name in the catalog, one per line. |
| `catalog validate` | Validate the embedded catalog; exits non-zero and lists errors if anything is invalid. |
| `translate <locale> <key>` | Print one translated string from the embedded Fluent translations. |
| `locales` | List the locale codes this build embeds translations for. |
| `scan [--quarantine <keep\|now\|sevendays>]` | Read-only scan of the whole catalog against this machine. Deletes nothing. |
| `remove [--quarantine <keep\|now\|sevendays>] --confirm` | Runs the full removal engine for real. Requires `--confirm`; refuses to run if the process isn't elevated. |

`--quarantine` (on `scan` and `remove`) controls what happens to items
the catalog flags as quarantine-eligible:

- `keep` (default) — leave them where they are
- `now` — delete them immediately
- `sevendays` — leave them for now, but schedule their real deletion 7
  days later via a one-time Windows Scheduled Task

`kprm.exe --quarantine-cleanup <file>` is an internal entry point that
7-day scheduled task uses to rerun the deletion headlessly — not meant
to be invoked directly.

#### Examples

```bash
# See what's on this machine without touching anything
kprm.exe scan

# Remove everything found, keeping quarantine-eligible items in place
kprm.exe remove --confirm

# Remove everything found, deleting quarantine-eligible items after 7 days
kprm.exe remove --quarantine sevendays --confirm

# Inspect the embedded catalog
kprm.exe catalog stats
kprm.exe catalog validate
```

## Supported tools

KpRm's catalog currently knows how to detect and clean up after 202
tools: third-party cleanup/removal utilities, rootkit scanners,
ransomware decryptors, and diagnostic tools commonly run (and left
behind) during a malware-removal session.

<details>
<summary><strong>Show all 202 tools</strong></summary>

| | | | |
|---|---|---|---|
| AdliceDiag | AdminRun | Ads | AdsFix |
| AdwCleaner | AHK_NavScan | AlphaDecrypter | AswMBR |
| AuroraDecrypter | AutorunsVTChecker | Avast Decryptor Cryptomix | AVCertClean |
| Avenger | Avira Registry Cleaner | BitKangarooDecrypter | BitStakDecrypter |
| BlitzBlank | BTCWareDecrypter | Catchme | Check Browsers LNK |
| CKScanner | Clean_DNS | ClearLNK | CMD_Command |
| CoinVaultDecryptor | Combofix | Crypt38Decrypter | CryptoSearch |
| CrystalDiskInfo (portable) | DCryDecrypter | DDS | Decrypt CryptON |
| Defogger | DoesNotBelong | Dr.Web Cureit | Dr.Web LiveDisk |
| Easy Restore Point | Emisoft Emergency Kit | ESET AES-NI Decryptor | ESET Bedep Cleaner |
| ESET Bubnix Cleaner | ESET CodplatAA Cleaner | ESET Conficker Cleaner | ESET Crypt888 Decryptor |
| ESET Crysis Decryptor | ESET Daonol Cleaner | ESET Dorkbot Cleaner | ESET ELEX Cleaner |
| ESET Eternal Blue Checker | ESET Filecoder Cleaner | ESET Filecoder.AA Cleaner | ESET Filecoder.AE Cleaner |
| ESET Filecoder.AR Cleaner | ESET Filecoder.NAC Cleaner | ESET Filecoder.R Cleaner | ESET GandCrab Decryptor |
| ESET Goblin Cleaner | ESET JS/Bondat Fixer | ESET Log Collector | ESET Mabezat Decryptor |
| ESET Mebroot Cleaner | ESET Medre Cleaner | ESET Necurs.A Cleaner | ESET Olmarik Cleaner |
| ESET Online Scanner | ESET Poweliks Cleaner | ESET Quervar.C Cleaner | ESET Retacino Cleaner |
| ESET Retefe Detector | ESET Rogue Applications Remover | ESET Rovnix.A Cleaner | ESET Simda Cleaner |
| ESET Sirefef Cleaner | ESET Spy.Tuscas Cleaner | ESET Spy.Zbot.ZR Cleaner | ESET SpyEye Cleaner |
| ESET Superfish Cleaner | ESET SysInspector | ESET SysRescue | ESET TeslaCrypt Decryptor |
| ESET Trustezeb.A Decoder | ESET VB.NAX Cleaner | ESET VB.OGJ Cleaner | ESET Virlock Cleaner |
| ESET Zimuse Cleaner | FilesLockerDecrypter | FixExec | FixPurge |
| FRST | FSS | g3n-h@ckm@n tools | GetSystemInfo |
| GhostCryptDecrypter | GibonDecrypter | GooredFix | Grantperms |
| HiddenTear Bruteforcer | HiddenTearDecrypter | Hosts-perm | HostsXpert |
| InsaneCryptDecrypter | JavaRa | JigSawDecrypter | Junkware Removal Tool |
| Kaspersky Rescue Disk | Kaspersky Virus Removal Tool | KPLive | KPTemp |
| ListCWall | ListParts | LogonFix | Look_my_hardware |
| Malwarebytes (log) | Malwarebytes Anti-Rootkit | Malwarebytes Support Tool | Mbr.exe |
| MBRCheck | MbrScan | McAfee GetSusp | McAfee Pinkslipbot |
| McAfee RootkitRemover | McAfee Stinger | McAfee Tesladecrypt | MemControl |
| Microsoft Safety Scanner | MiniregTool | Minitoolbox | MirCopDecrypter |
| MKV | Mole02Decryptor | NetAdapter Repair All In One | OldTimer Tools |
| OneClick2RP | OTA | OTC | OTH |
| OTL | OTM | OTS | PCHunter |
| PowerLockyDecrypter | Pre_Scan | Process Analyzer | ProcessClose |
| QuickDiag | Rakhni Decryptor | Rannoh Decryptor | RansomNoteCleaner |
| RAV | RegtoolExport | Remediate VBS Worm | Report_Antivir |
| Report_CHKDSK | ResetBrowser | ResetNavigator | Rkill |
| RogueKiller | RogueKillerCMD | Rooter | RootkitRevealer |
| RstAssociations | RstHosts | ScanRapide | SEAF |
| SecurityCheck | ServicesRepair | SFT | ShadeDecryptor |
| Shortcut Cleaner | SMBCheck | StrikedDecrypter | StupidDecrypter |
| Symantec Kovter Removal Tool | Symantec Pasobir Removal Tool | Symantec Ramnit Removal Tool | Symantec Tempedreve Removal Tool |
| System Information Tool | Systemlook | TDSSKiller | TFC |
| ToolsDiag | UAC Manager | UAC-Level | UnHide |
| Unlock92Decrypter | UnZacMe | USB File Resc | USBFix |
| Webroot DE-BUG | WildfireDecryptor | WinCHK | Windows Repair All In One (portable) |
| WinsockAnalyzer | WinUpdatefix | XoristDecryptor | ZHP Tools |
| ZHPCleaner | ZHPDiag | ZHPFix | ZHPLite |
| ZHPSuite | Zoek | | |

</details>

Each entry is one `tools.d/<name>.toml` file describing what to look
for (file/folder/registry-key/process name patterns, optionally scoped
to a matching PE `CompanyName`) and what to do about each match. See
[`../docs/RUST-REWRITE-SPEC.md`](../docs/RUST-REWRITE-SPEC.md) Annex B
for the full action-type schema if you're adding or editing an entry.

## Architecture

Five crates:

| Crate | Role |
|---|---|
| [`kprm-catalog`](crates/kprm-catalog) | Data model, loader, and validator for the 202-tool catalog (`tools.d/*.toml`), embedded into the binary at compile time. |
| [`kprm-engine`](crates/kprm-engine) | Pure, platform-independent removal logic: pattern matching, quarantine decisions, the action-type orchestrator (kills matching running processes before deleting a selected target), UAC/system-settings restoration, registry-backup planning and restore planning, restore-point and deferred-quarantine scheduling, report formatting (plain text and JSON). No Windows dependency — fully unit-tested on any OS with in-memory fakes. |
| [`kprm-i18n`](crates/kprm-i18n) | Fluent-based translations for 8 locales, with variable substitution (`get_fmt`); powers every label in the GUI (see [Usage](#graphical-interface) above), auto-selected from the Windows UI language. |
| [`kprm-windows`](crates/kprm-windows) | Real Windows adapters implementing `kprm-engine`'s abstractions: filesystem, registry, processes, external commands, elevation, machine restart, registry-hive export/restore, quarantine-scheduling agent, UI locale detection, single-instance mutex/message box, and delayed self-deletion. |
| [`kprm`](crates/kprm) | The single binary: the GUI (egui/eframe) with no arguments, the CLI with a subcommand. |

See [`BUILDING.md`](BUILDING.md) for how to build it from source
(toolchain requirements and a few environment-specific gotchas), and
[`../docs/RUST-REWRITE-SPEC.md`](../docs/RUST-REWRITE-SPEC.md) for the
full design rationale behind this rewrite.

## Testing

`cargo test --workspace` runs 121 unit tests: `kprm-engine`'s pure
logic is tested entirely with in-memory fakes, no Windows dependency
at all, while `kprm-windows`'s adapters are tested for real — but only
ever against disposable state (temp files, a private registry
subtree, processes the tests spawn themselves), never the real
Desktop, Program Files, or system-wide registry. See
[`BUILDING.md`](BUILDING.md) for details, including the handful of
tests that need real elevation and skip themselves gracefully when it
isn't available.

## License

GPL-3.0-or-later, same as the original AutoIt3 project.
