//! Persists the timestamp of the last successful automatic/custom-removal
//! run — shown in the Automatic tab's sidebar stat card ("Dernier passage",
//! `docs/design/Main.dc.html`). New in the Win32 rewrite: the original
//! never persisted anything between runs.

use crate::ports::Registry;

const KEY: &str = "HKCU\\Software\\KpRm";
const VALUE_NAME: &str = "LastRun";

/// Records `timestamp` (the same 14-digit format `kprm_windows::current_timestamp`
/// produces elsewhere, e.g. for backup folder names) as the last run time.
pub fn record(registry: &mut impl Registry, timestamp: &str) -> bool {
    registry.write_string(KEY, VALUE_NAME, timestamp)
}

/// The last recorded run timestamp, if any run has completed since this
/// feature was added.
pub fn read(registry: &impl Registry) -> Option<String> {
    registry.read_value(KEY, VALUE_NAME)
}
