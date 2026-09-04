//! Platform-independent removal logic shared by every KpRm front-end
//! (GUI, CLI, the deferred-quarantine headless run). See
//! docs/RUST-REWRITE-SPEC.md §5.1: this crate depends on no Windows API —
//! everything here is unit-tested on any OS. A future `kprm-windows` crate
//! provides the real filesystem/registry/process adapters that feed this
//! logic with actual data.

pub mod matcher;
pub mod paths;
pub mod quarantine;
pub mod registry;
pub mod whitelist;
