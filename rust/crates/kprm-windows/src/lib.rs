//! Real Windows adapters for the [`kprm_engine::ports`] traits. Everything
//! in this crate touches an actual machine — it has no unit tests that fake
//! their way around Windows (that's `kprm-engine`'s job); tests here run for
//! real, but only ever against throwaway temp files/folders, a private
//! `HKCU\Software\KpRmRustTests` registry subtree, or a process this test
//! suite spawned itself. See docs/RUST-REWRITE-SPEC.md §3.

pub mod command;
pub mod filesystem;
pub mod known_dirs;
pub mod process;
pub mod registry;
pub mod version_info;

pub use command::RealCommandRunner;
pub use filesystem::WinFileSystem;
pub use known_dirs::{is_64bit_os, EnvKnownDirs};
pub use process::WinProcessManager;
pub use registry::WinRegistry;
