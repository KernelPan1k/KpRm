//! A `YYYYMMDDHHMMSS` timestamp for report filenames, matching the original's
//! `$sCurrentTime` (`src/kp_includes/variables.au3`). Uses `GetLocalTime`
//! directly (already depend on `windows` for everything else here) rather
//! than pulling in a date/time crate for one struct.

use windows::Win32::System::SystemInformation::GetLocalTime;

/// `YYYYMMDDHHMMSS`, local time.
pub fn current_timestamp() -> String {
    let st = unsafe { GetLocalTime() };
    format!(
        "{:04}{:02}{:02}{:02}{:02}{:02}",
        st.wYear, st.wMonth, st.wDay, st.wHour, st.wMinute, st.wSecond
    )
}

/// `(year, month, day, hour, minute)`, local time — the raw fields
/// [`kprm_engine::quarantine_schedule::add_days`] needs to compute a
/// `schtasks.exe` start date/time for the "Dans 7 jours" quarantine
/// schedule.
pub fn current_local_datetime_fields() -> (u32, u32, u32, u32, u32) {
    let st = unsafe { GetLocalTime() };
    (
        st.wYear as u32,
        st.wMonth as u32,
        st.wDay as u32,
        st.wHour as u32,
        st.wMinute as u32,
    )
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn produces_a_14_digit_numeric_timestamp() {
        let ts = current_timestamp();
        assert_eq!(ts.len(), 14);
        assert!(ts.chars().all(|c| c.is_ascii_digit()));
    }

    #[test]
    fn datetime_fields_are_plausible() {
        let (year, month, day, hour, minute) = current_local_datetime_fields();
        assert!((2020..2100).contains(&year));
        assert!((1..=12).contains(&month));
        assert!((1..=31).contains(&day));
        assert!(hour < 24);
        assert!(minute < 60);
    }
}
