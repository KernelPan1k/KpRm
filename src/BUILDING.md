# Building KpRm from source

This workspace targets `x86_64-pc-windows-gnu` and produces a single
portable executable, `kprm.exe`. Building it needs a **full MinGW-w64
toolchain**, not just the minimal one `rustup` installs — see below for
why and how.

## Requirements

- The `stable-x86_64-pc-windows-gnu` Rust toolchain (`rustup toolchain
  install stable-x86_64-pc-windows-gnu`). `rust-toolchain.toml` pins
  this automatically for anyone building inside this directory — see
  [Known quirks](#known-quirks) for why that file matters, not just the
  `x86_64-pc-windows-gnu` *target*.
- A full MinGW-w64 distribution (e.g. [WinLibs](https://winlibs.com/),
  UCRT variant, ~270 MB), installed somewhere stable (this project
  assumes `C:\mingw64`) and added to `PATH`.
- [Node.js](https://nodejs.org/), only if you need to regenerate the
  catalog from `../src/config/tools.xml` (see
  [Regenerating the tool catalog](#regenerating-the-tool-catalog)).

`rust/.cargo/config.toml` already points the GNU target's linker at
`C:/mingw64/bin/gcc.exe` — adjust that path if your MinGW-w64
installation lives elsewhere.

## Build & test

```bash
cargo build --workspace
cargo test --workspace
cargo build --release -p kprm
```

The release binary lands at `target/release/kprm.exe` (~4.9 MB) and is
fully self-contained: `objdump -p` shows it only imports from system
DLLs (`kernel32`, `user32`, `gdi32`, `opengl32`, the `api-ms-win-crt-*`
forwarders, ...). No installer, no bundled runtime, no third-party DLL
to ship alongside it — see the note about `rust-toolchain.toml` below
if you ever see a different result.

`cargo test --workspace` runs a large real-adapter test suite in
`kprm-windows` — real temp files, a private
`HKCU\Software\KpRmRustTests` registry subtree, and processes the tests
spawn themselves. It never touches the real Desktop, Program Files, or
`HKLM`. A handful of tests that need actual elevation (e.g. exporting a
registry hive) detect that they're not running elevated and skip
themselves with a message instead of failing — see
[Known quirks](#known-quirks) below.

## Regenerating the tool catalog

`tools.d/*.toml` (202 files, one per tool) was generated once from
`../src/config/tools.xml` by `scripts/migrate_tools_xml.mjs` (plain
Node.js, no dependencies). That script is a one-shot migration tool —
`tools.xml` remains the historical source, but the Rust code no longer
reads it after this migration. Re-run the script only if you need to
regenerate the catalog from a corrected `tools.xml`:

```bash
node scripts/migrate_tools_xml.mjs ../src/config/tools.xml tools.d
```

## Why a full MinGW-w64 toolchain, and not just `rustup`'s

`kprm-catalog`, `kprm-engine`, `kprm-i18n`, and `kprm-windows` all build
fine with the minimal GNU toolchain `rustup` installs on its own.
`kprm` — which embeds the GUI (`egui`/`eframe`/`winit`) even in its CLI
mode, since the CLI and GUI were merged into one binary — does not.

Several of its dependencies (`parking_lot_core`, `libloading`, and
`clap`'s color-terminal support before it was disabled) use Rust's
`raw-dylib` linking mechanism, which needs a real `dlltool.exe` +
`as.exe`. `rustup`'s bundled GNU toolchain ships neither — its
`dlltool.exe`/`gcc.exe` are minimal, self-contained stand-ins without a
real assembler. Worse: even with a working `dlltool`/`as`, the
`ld.exe` that ships with `rustup`'s toolchain has a known `raw-dylib`
codegen bug on the GNU target, producing `undefined reference to
_head_..._kernel32_dll_imports_lib` regardless.

The fix that actually worked: install a full external MinGW-w64
distribution (WinLibs, UCRT-based) and point rustc's linker at its
`gcc.exe` instead of the one `rustup` ships, via
`rust/.cargo/config.toml`:

```toml
[target.x86_64-pc-windows-gnu]
linker = "C:/mingw64/bin/gcc.exe"
ar = "C:/mingw64/bin/ar.exe"
```

It's specifically the newer/complete `ld` that ships with a full MinGW
distribution that resolves the `raw-dylib` error — not merely having
`dlltool` on `PATH`. `cargo-xwin`/the MSVC target was also tried as an
alternative, but that path needs `clang-cl`, which wasn't available
either — not pursued further once the GNU + full-MinGW route worked.

**Accepted trade-off:** WinLibs' UCRT-based distribution requires
Windows 10 (1607+) or later — a reasonable floor for a 2026 rewrite,
but worth knowing if Windows 7/8.1 support ever mattered (in which case
target an `msvcrt`-based MinGW distribution instead of UCRT).

Before `egui`/`winit` entered the picture, `clap`'s default
color-terminal feature alone already triggered the same `dlltool`
requirement; it was initially built with `default-features = false` to
avoid installing a full MinGW toolchain just for the CLI. That's no
longer relevant now that the CLI and GUI are one binary and always pull
in `egui`/`winit` regardless.

## Known quirks

A few non-obvious things that cost real debugging time, kept here so
they don't get rediscovered from scratch:

- **`rustup target add x86_64-pc-windows-gnu` is not enough — the
  active *toolchain* (not just the target) must be GNU-hosted.**
  `.cargo/config.toml`'s `[target.x86_64-pc-windows-gnu]` linker
  override only applies once a build actually targets GNU. Adding the
  GNU *target* to an otherwise-default `stable-x86_64-pc-windows-msvc`
  toolchain doesn't do that on its own: plain `cargo build --release`
  (no `--target` flag, no `[build] target` in cargo config) always
  builds for the active toolchain's own host, so on a machine whose
  rustup default is MSVC-hosted, it silently produces an MSVC-linked
  `kprm.exe` instead — dynamically linked against the real Visual C++
  runtime (`VCRUNTIME140.dll`), which isn't part of Windows and is
  missing on any machine without the Visual C++ Redistributable
  installed ("il manque vcruntime140.dll"). Confirmed by comparing
  `objdump -p` output (and the presence/absence of a linker "Rich"
  header, which only MSVC's `link.exe` emits) between a plain
  `cargo build --release` under a default MSVC-hosted toolchain versus
  the same command under `stable-x86_64-pc-windows-gnu` — only the
  latter is free of any `VCRUNTIME140.dll` import. `rust-toolchain.toml`
  (pinning `channel = "stable-x86_64-pc-windows-gnu"`) fixes this for
  good: it makes rustup select the right toolchain automatically for
  anyone building inside this directory, regardless of their global
  `rustup default`.

- **Accented Windows usernames break the GNU linker.** If the Windows
  account name contains an accented character (`C:\Users\Prénom...`),
  install the Rust toolchain (`RUSTUP_HOME`/`CARGO_HOME`) **and**
  redirect `%TEMP%`/`%TMP%` to an unaccented path — the GNU linker (and
  `cargo install`, which builds under `%TEMP%`) silently fails to
  resolve accented paths (`ld: cannot find ...: No such file or
  directory` / `cannot find ...rlib` on files that demonstrably exist).
  This bites in two separate stages, both needing the same fix: first
  `ld` fails to find the toolchain's own sysroot `.rlib` files under
  `%RUSTUP_HOME%\toolchains\...` (fixed by relocating `RUSTUP_HOME`);
  once that's fixed, it then fails to find crates.io dependency import
  libs referenced via `-L <accented CARGO_HOME>\registry\src\...`
  (e.g. `cannot find -lwindows.0.52.0`, from `windows_x86_64_gnu`'s
  bundled `.a` — a raw-dylib forwarder lib, not a typo) — fixed the same
  way by also relocating `CARGO_HOME`. Concretely, this was fixed for
  this machine's `MickaëlMathieu` account by setting persistent user env
  vars `RUSTUP_HOME=C:\rustup` and `CARGO_HOME=C:\rustup\cargo`
  (`[System.Environment]::SetEnvironmentVariable(..., 'User')`), then
  reinstalling the toolchain there (`rustup toolchain install
  stable-x86_64-pc-windows-gnu`) and copying the existing
  `%USERPROFILE%\.cargo` registry cache over to avoid re-downloading it.
  **If a fresh shell ever shows the old accented-path failure again**
  (e.g. a reset sandbox/container that doesn't persist Windows user env
  vars across sessions), redo the same two `SetEnvironmentVariable`
  calls (or `setx`) and re-run `rustup toolchain install
  stable-x86_64-pc-windows-gnu` under those vars — the rest of the setup
  (MinGW at `C:\mingw64`, `.cargo/config.toml`) is unaffected.

- **MinGW always links its own manifest, silently overriding a custom
  one.** `gcc`'s spec unconditionally links `default-manifest.o`
  (`asInvoker`) into every executable — including `kprm.exe`, which
  needs `requireAdministrator` (`assets/app.manifest`) instead. The two
  collide (`ld: .rsrc merge failure: multiple non-default manifests`),
  and MinGW's silently wins if left alone. Confirmed by extracting the
  actual `RT_MANIFEST` resource Windows reads
  (`FindResource`/`LoadResource`) rather than trusting the linker
  warning. Worked around in `build.rs` by pointing gcc's `-B` search
  path at an empty stand-in `default-manifest.o`
  (`crates/kprm/nodefaultmanifest/`, no `.rsrc` section) that shadows
  MinGW's real one, leaving the app's own manifest as the only survivor.

- **`RegSaveKeyExW` needs `SeBackupPrivilege` actually *held* by the
  token, not just an administrator account.** A standard (non-elevated)
  token doesn't carry the privilege at all, even for an admin user —
  `AdjustTokenPrivileges` reports success while silently granting
  nothing, and `RegSaveKeyExW` then fails with `ERROR_PRIVILEGE_NOT_HELD`
  (1314). The registry-backup test detects this (via
  `kprm_windows::is_elevated()`) and skips itself with a message rather
  than failing when run outside an elevated shell.

- **`PrintWindow` is not reliable for verifying `egui` layouts in every
  environment.** In at least one development environment (no composed
  desktop / no active DWM session), `PrintWindow(hwnd, hdc,
  PW_RENDERFULLCONTENT)` — even combined with a forced `MoveWindow` to
  trigger a real repaint — returned stale or incorrect window content
  that didn't reflect what egui had actually laid out. This was only
  caught by instrumenting the code to print the real computed
  `Response.rect` values via `eprintln!` and comparing them against
  what the screenshot showed. If a screenshot of this GUI looks broken
  in a similar headless/non-interactive environment, don't trust it —
  verify with real printed coordinates instead, or check on an
  interactive Windows session.

- **(Historical, resolved) `eframe`'s `glow` (OpenGL) renderer required
  OpenGL 2.0+, which wasn't a given on every machine this tool is meant
  to run on** — a VM or remote session with only a generic/basic display
  adapter could be stuck on OpenGL 1.1, failing the GUI outright. This is
  the reason the GUI was rewritten from `eframe`/`egui` to native Win32/
  GDI+ (no OpenGL, no `wgpu`, no bundled software renderer) — see the
  rewrite plan and `src/crates/kprm-win32gui`. `kprm` now also declares
  `#![windows_subsystem = "windows"]` (`kprm/src/main.rs`), since the
  console it used to keep around for exactly this failure's error message
  no longer serves a purpose — a normal launch shows no console window at
  all, while the CLI subcommands still print to an existing terminal
  normally when run from one.
