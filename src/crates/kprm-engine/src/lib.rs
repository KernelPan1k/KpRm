//! Platform-independent removal logic shared by every KpRm front-end
//! (GUI, CLI, the deferred-quarantine headless run). See
//! docs/RUST-REWRITE-SPEC.md §5.1: this crate depends on no Windows API —
//! everything here is unit-tested on any OS. `kprm-windows` provides the
//! real filesystem/registry/process adapters ([`ports`]) that
//! [`orchestrator::run_tool_actions`] runs against.

pub mod backup;
pub mod diagnostics;
pub mod fakes;
pub mod last_run;
pub mod maintenance;
pub mod matcher;
pub mod orchestrator;
pub mod paths;
pub mod ports;
pub mod quarantine;
pub mod quarantine_schedule;
pub mod registry;
pub mod report;
pub mod restore_point;
pub mod system_info;
pub mod system_settings;
pub mod uac;
pub mod whitelist;
