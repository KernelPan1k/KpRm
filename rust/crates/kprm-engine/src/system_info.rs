//! System/environment info shown at the top of a report (username, machine
//! name, OS build, run count...) — pure formatting only, the same idea as
//! the original's report header (`src/kp_includes/functions/functions.au3`
//! lines 17-23: "# Run by", "# Computer Name", "# OS", "# Number of
//! passes"). `kprm-windows` is responsible for actually reading these
//! values off the real machine (env vars, registry, counting past report
//! files) and building this struct.

#[derive(Debug, Clone, Default, PartialEq, Eq)]
pub struct SystemInfo {
    pub username: String,
    pub computer_name: String,
    pub os_name: String,
    pub os_build: String,
    pub is_64bit: bool,
    /// How many KpRm reports already exist for this machine — i.e. which
    /// run this is (the original's `CountKpRmPass`).
    pub pass_number: usize,
}

impl SystemInfo {
    /// Renders as a handful of aligned "Label : value" lines, meant to sit
    /// in a report's title block alongside the version/date lines.
    pub fn to_lines(&self) -> Vec<String> {
        vec![
            format!("Utilisateur        : {}", self.username),
            format!("Ordinateur         : {}", self.computer_name),
            format!(
                "Système            : {} ({}) - build {}",
                self.os_name,
                if self.is_64bit { "64 bits" } else { "32 bits" },
                self.os_build
            ),
            format!("Nombre de passages : {}", self.pass_number),
        ]
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn formats_every_field() {
        let info = SystemInfo {
            username: "Bob".to_string(),
            computer_name: "DESKTOP-ABC123".to_string(),
            os_name: "Windows 11 Pro".to_string(),
            os_build: "22631.2861".to_string(),
            is_64bit: true,
            pass_number: 3,
        };

        let lines = info.to_lines();

        assert!(lines.iter().any(|l| l.contains("Bob")));
        assert!(lines.iter().any(|l| l.contains("DESKTOP-ABC123")));
        assert!(lines.iter().any(|l| l.contains("Windows 11 Pro")
            && l.contains("64 bits")
            && l.contains("22631.2861")));
        assert!(lines
            .iter()
            .any(|l| l.contains("Nombre de passages") && l.contains('3')));
    }

    #[test]
    fn flags_32bit_machines() {
        let info = SystemInfo {
            is_64bit: false,
            ..Default::default()
        };
        assert!(info.to_lines().iter().any(|l| l.contains("32 bits")));
    }
}
