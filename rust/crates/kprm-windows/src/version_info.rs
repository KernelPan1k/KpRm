//! Reads the `CompanyName` version-resource string from a `.exe`/`.com`,
//! ported from the `FileGetVersion($sFile, "CompanyName")` calls scattered
//! through `src/kp_includes/functions/remove.au3`. See
//! docs/RUST-REWRITE-SPEC.md §3.7.
//!
//! Uses `pelite` to parse the PE resource directory directly from the file's
//! bytes rather than calling the Win32 version-info API
//! (`GetFileVersionInfoW`/`VerQueryValueW`) — a pure, dependency-light PE
//! parse that happens to also make this function (unlike the rest of this
//! crate) portable to any OS for testing against sample binaries, though it
//! is only ever exercised for real from Windows-only callers here.

use pelite::resources::version_info::Visit;
use pelite::{FileMap, PeFile};

struct CompanyNameVisitor {
    company_name: Option<String>,
}

impl Visit<'_> for CompanyNameVisitor {
    fn string(&mut self, key: &[u16], value: &[u16]) {
        if self.company_name.is_some() {
            return;
        }
        let key = String::from_utf16_lossy(key);
        if key == "CompanyName" {
            self.company_name = Some(String::from_utf16_lossy(value));
        }
    }
}

/// Reads `path`'s `CompanyName` version-resource field, or `None` if the
/// file can't be opened, isn't a PE image, or carries no such field.
pub fn read_company_name(path: &str) -> Option<String> {
    let file_map = FileMap::open(path).ok()?;
    let pe = PeFile::from_bytes(file_map.as_ref()).ok()?;
    let resources = pe.resources().ok()?;
    let version_info = resources.version_info().ok()?;

    let mut visitor = CompanyNameVisitor { company_name: None };
    version_info.visit(&mut visitor);
    visitor
        .company_name
        .map(|s| s.trim_end_matches('\0').to_string())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn missing_file_yields_none() {
        assert_eq!(read_company_name(r"C:\this\path\does\not\exist.exe"), None);
    }

    #[test]
    fn non_pe_file_yields_none() {
        let dir = std::env::temp_dir();
        let path = dir.join(format!("kprm-not-a-pe-{}.exe", std::process::id()));
        std::fs::write(&path, b"not a real PE file").unwrap();

        assert_eq!(read_company_name(path.to_str().unwrap()), None);

        std::fs::remove_file(&path).ok();
    }

    #[cfg(windows)]
    #[test]
    fn reads_the_real_company_name_of_a_known_system_binary() {
        // notepad.exe ships on every Windows install with a real
        // Microsoft-signed CompanyName field — a stable, side-effect-free
        // fixture for this test (never launched, only its bytes are read).
        let windir = std::env::var("SystemRoot").unwrap_or_else(|_| r"C:\Windows".to_string());
        let notepad = format!("{windir}\\System32\\notepad.exe");

        let company = read_company_name(&notepad);
        assert_eq!(company.as_deref(), Some("Microsoft Corporation"));
    }
}
