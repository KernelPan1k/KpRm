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

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn produces_a_14_digit_numeric_timestamp() {
        let ts = current_timestamp();
        assert_eq!(ts.len(), 14);
        assert!(ts.chars().all(|c| c.is_ascii_digit()));
    }
}
