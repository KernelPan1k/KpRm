//! Runs an external program to completion, implementing
//! [`kprm_engine::ports::CommandRunner`] — the real counterpart of
//! `RunWait` calls scattered through the original (`schtasks.exe`,
//! `netsh.exe`, a tool's own uninstaller, ...).

use std::os::windows::process::CommandExt;

use kprm_engine::ports::CommandRunner;

/// Prevents a console window from flashing up for each of these background
/// commands, matching the original's `@SW_HIDE` on every `RunWait` call.
const CREATE_NO_WINDOW: u32 = 0x0800_0000;

pub struct RealCommandRunner;

impl CommandRunner for RealCommandRunner {
    fn run(&mut self, program: &str, args: &[&str]) -> bool {
        std::process::Command::new(program)
            .args(args)
            .creation_flags(CREATE_NO_WINDOW)
            .status()
            .map(|status| status.success())
            .unwrap_or(false)
    }

    fn run_capture(&mut self, program: &str, args: &[&str]) -> Option<String> {
        let output = std::process::Command::new(program)
            .args(args)
            .creation_flags(CREATE_NO_WINDOW)
            .output()
            .ok()?;
        output
            .status
            .success()
            .then(|| String::from_utf8_lossy(&output.stdout).into_owned())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn runs_a_harmless_real_command_successfully() {
        let mut runner = RealCommandRunner;
        assert!(runner.run("cmd.exe", &["/c", "exit 0"]));
    }

    #[test]
    fn reports_failure_for_a_nonzero_exit_code() {
        let mut runner = RealCommandRunner;
        assert!(!runner.run("cmd.exe", &["/c", "exit 1"]));
    }

    #[test]
    fn reports_failure_for_a_program_that_does_not_exist() {
        let mut runner = RealCommandRunner;
        assert!(!runner.run("this-program-does-not-exist.exe", &[]));
    }

    #[test]
    fn run_capture_returns_real_stdout_on_success() {
        let mut runner = RealCommandRunner;
        let output = runner.run_capture("cmd.exe", &["/c", "echo hello-kprm"]);
        assert!(output.unwrap().contains("hello-kprm"));
    }

    #[test]
    fn run_capture_returns_none_for_a_nonzero_exit_code() {
        let mut runner = RealCommandRunner;
        assert!(runner.run_capture("cmd.exe", &["/c", "exit 1"]).is_none());
    }
}
