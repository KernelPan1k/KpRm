//! System diagnostic scanner — collects environment data and formats it as a
//! plain-text report that a technician can share on a support forum or keep
//! as a paper trail.
//!
//! Everything here is read-only: no files are modified, no registry keys are
//! written. Individual sections are gathered independently so a failure in one
//! (PowerShell unavailable, access denied) never aborts the whole scan.
//!
//! The report text is always English, regardless of the app's own display
//! language (`kprm-i18n`/the GUI's language setting) — it's meant to be
//! pasted into an English-language support forum thread or handed to a
//! technician who may not read the operator's language, so it deliberately
//! does not go through `kprm-i18n` at all.

use crate::paths::KnownDirs;
use crate::ports::{CommandRunner, ProcessManager};

// ── Public types ─────────────────────────────────────────────────────────────

/// One named section inside the diagnostic report.
#[derive(Debug)]
pub struct DiagSection {
    pub title: String,
    pub lines: Vec<String>,
}

/// The assembled diagnostic report.
#[derive(Debug)]
pub struct DiagnosticReport {
    pub generated_at: String,
    pub sections: Vec<DiagSection>,
}

impl DiagnosticReport {
    /// Formats the report as a UTF-8 string (with BOM) suitable for writing
    /// to a text file and opening in Notepad / any text editor.
    /// The BOM (\u{FEFF}) ensures Notepad correctly detects UTF-8 encoding
    /// regardless of Windows locale settings.
    pub fn to_text(&self) -> String {
        let sep = "=".repeat(80);
        // UTF-8 BOM — ensures Notepad (and any other editor) detects the
        // encoding correctly even on systems whose ANSI code page isn't UTF-8.
        let mut out = String::from('\u{FEFF}');

        out.push_str(&sep);
        out.push('\n');
        out.push_str(&format!(
            "KpRm v{} — Diagnostic Report — {}\n",
            env!("CARGO_PKG_VERSION"),
            self.generated_at
        ));
        out.push_str("https://github.com/KernelPan1k/KpRm\n");
        out.push_str(&sep);
        out.push('\n');

        for s in &self.sections {
            out.push('\n');
            out.push_str(&format!("--- {} ---\n", s.title));
            if s.lines.is_empty() {
                out.push_str("(no entries)\n");
            } else {
                for line in &s.lines {
                    out.push_str(line);
                    out.push('\n');
                }
            }
        }
        out
    }
}

// ── Entry point ───────────────────────────────────────────────────────────────

/// Collects all diagnostic sections and returns the assembled report.
pub fn collect(
    processes: &dyn ProcessManager,
    commands: &mut dyn CommandRunner,
    dirs: &dyn KnownDirs,
    timestamp: &str,
) -> DiagnosticReport {
    DiagnosticReport {
        generated_at: timestamp.to_string(),
        sections: vec![
            section_windows_activation(commands),
            section_system_info(commands),
            section_windows_events(commands),
            section_security_tools(commands),
            section_firewall_profiles(commands),
            section_processes(processes, commands),
            section_services(commands),
            section_drivers(commands),
            section_startup(commands),
            section_scheduled_tasks(commands),
            section_installed_software(commands),
            section_browser_extensions(commands),
            section_recent_files(commands),
            section_hosts_file(commands, dirs),
            section_network(commands),
            section_winsock_catalog(commands),
            section_proxy(commands),
            section_browser_policies(commands),
            section_file_associations(commands),
            section_explorer_settings(commands),
        ],
    }
}

// ── Private helpers ───────────────────────────────────────────────────────────

/// Runs a PowerShell script and returns its non-empty output lines.
///
/// Forces `[Console]::OutputEncoding` to UTF-8 before the caller's script so
/// that `run_capture` (which reads stdout as UTF-8 bytes) receives correctly
/// encoded text. Without this, PowerShell defaults to the system OEM code page
/// (CP850 / CP1252) and accented characters arrive as mojibake.
fn ps(commands: &mut dyn CommandRunner, script: &str) -> Vec<String> {
    let full = format!(
        "[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;\
         $OutputEncoding=[System.Text.Encoding]::UTF8\n{script}"
    );
    commands
        .run_capture(
            "powershell.exe",
            &["-NoProfile", "-NonInteractive", "-Command", &full],
        )
        .unwrap_or_default()
        .lines()
        .map(str::to_string)
        .filter(|l| !l.trim().is_empty())
        .collect()
}

fn section(title: &str, lines: Vec<String>) -> DiagSection {
    DiagSection { title: title.to_string(), lines }
}

// ── Sections ──────────────────────────────────────────────────────────────────

fn section_windows_activation(commands: &mut dyn CommandRunner) -> DiagSection {
    let script = r#"
$ErrorActionPreference='SilentlyContinue'
$products = Get-CimInstance SoftwareLicensingProduct -EA SilentlyContinue |
    Where-Object { $_.Name -like '*Windows*' -and $_.PartialProductKey }
if (!$products) { "Unable to retrieve license information."; return }
foreach ($s in $products) {
    $statusText = switch ($s.LicenseStatus) {
        0 { "[NOT LICENSED] No valid license detected" }
        1 { "[ACTIVATED] Valid license" }
        2 { "[GRACE] Initial grace period (OOB)" }
        3 { "[GRACE] Out of tolerance" }
        4 { "[SUSPECT] Non-compliant activation detected — likely KMS/crack" }
        5 { "[NOTIFICATION] Notification required" }
        6 { "[EXTENDED GRACE] Extended grace period" }
        default { "[UNKNOWN ($($s.LicenseStatus))]" }
    }
    "Product      : $($s.Name)"
    "Status       : $statusText"
    if ($s.Description) { "Description  : $($s.Description)" }
    # KMS indicators
    if ($s.DiscoveredKeyManagementServiceMachineName) {
        "KMS Server   : $($s.DiscoveredKeyManagementServiceMachineName):$($s.DiscoveredKeyManagementServiceMachinePort)"
        "⚠ KMS activation detected — verify whether this server is legitimate (company/school) or suspicious (crack/third-party tool)"
    }
    if ($s.GracePeriodRemaining -gt 0) {
        $days = [math]::Round($s.GracePeriodRemaining / 1440, 1)
        "Grace        : $days day(s) remaining"
    }
    # Check for known illegitimate activation tools via running processes
    $suspectProcs = @('KMSAuto','KMSpico','AAct','MAS','AutoKMS','Re-Loader','KMS_VL_ALL')
    $found = Get-Process -EA SilentlyContinue | Where-Object {
        $name = $_.Name
        $suspectProcs | Where-Object { $name -like "*$_*" }
    }
    if ($found) {
        "⚠ Suspicious process detected: $($found.Name -join ', ') — third-party activation tool running"
    }
    ""
}
"#;
    section("WINDOWS ACTIVATION", ps(commands, script))
}

fn section_system_info(commands: &mut dyn CommandRunner) -> DiagSection {
    let script = r#"
$ErrorActionPreference='SilentlyContinue'
$o = Get-CimInstance Win32_OperatingSystem
$c = Get-CimInstance Win32_ComputerSystem
$p = (Get-CimInstance Win32_Processor | Select-Object -First 1)
$b = Get-CimInstance Win32_BIOS
$u = Get-CimInstance Win32_UserAccount -Filter "LocalAccount=True AND Disabled=False" | ForEach-Object {$_.Name} | Sort-Object
"OS          : $($o.Caption)"
"Build       : $($o.BuildNumber) — $($o.OSArchitecture)"
"Install     : $($o.InstallDate.ToString('yyyy-MM-dd'))"
"Boot        : $($o.LastBootUpTime.ToString('yyyy-MM-dd HH:mm'))"
"CPU         : $($p.Name) ($($p.NumberOfCores) cores / $($p.NumberOfLogicalProcessors) threads)"
"RAM         : $([math]::Round($c.TotalPhysicalMemory/1GB,2)) GB"
"Machine     : $($c.Name)"
"Manufacturer: $($c.Manufacturer) — $($c.Model)"
"BIOS        : $($b.Manufacturer) $($b.SMBIOSBIOSVersion) ($($b.ReleaseDate.ToString('yyyy-MM-dd')))"
"Domain      : $($c.Domain)"
"User        : $env:USERNAME ($env:USERDOMAIN)"
"Active local accounts : $($u -join ', ')"
"PowerShell  : $($PSVersionTable.PSVersion)"
"CLR         : $([System.Runtime.InteropServices.RuntimeEnvironment]::GetSystemVersion())"
"Secure Boot : $((Confirm-SecureBootUEFI -EA SilentlyContinue))"
"UAC         : $(try{(Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System).EnableLUA}catch{'N/A'})"
"#;
    section("SYSTEM INFORMATION", ps(commands, script))
}

fn section_windows_events(commands: &mut dyn CommandRunner) -> DiagSection {
    let script = r#"
$ErrorActionPreference='SilentlyContinue'
$since = (Get-Date).AddDays(-7)
$events = Get-WinEvent -FilterHashtable @{LogName='Application','System'; Level=1,2; StartTime=$since} -MaxEvents 100 -EA SilentlyContinue |
    Sort-Object TimeCreated -Descending
if (!$events) { "No error/critical entries in the Application and System logs (last 7 days)."; return }
foreach ($e in $events) {
    $msg = ($e.Message -split "`r?`n")[0]
    if ($msg.Length -gt 300) { $msg = $msg.Substring(0,300) + '…' }
    "[$($e.TimeCreated.ToString('yyyy-MM-dd HH:mm'))] $($e.LogName) — $($e.ProviderName) (ID $($e.Id)) — $($e.LevelDisplayName)"
    "    $msg"
}
"#;
    section(
        "WINDOWS ERRORS (Application/System logs, last 7 days)",
        ps(commands, script),
    )
}

fn section_security_tools(commands: &mut dyn CommandRunner) -> DiagSection {
    let script = r#"
$ErrorActionPreference='SilentlyContinue'
"--- Antivirus (Windows Security Center) ---"
$av = Get-CimInstance -Namespace root/SecurityCenter2 -ClassName AntiVirusProduct -EA SilentlyContinue
if ($av) {
    $av | Sort-Object displayName | ForEach-Object {
        $state = $_.productState
        # productState bits: 0x10 = enabled, 0x12 = enabled+up-to-date
        $enabled = ($state -band 0x1000) -ne 0
        $upToDate = ($state -band 0x0010) -eq 0
        "  $($_.displayName) — Enabled: $enabled | Up to date: $upToDate | GUID: $($_.instanceGuid)"
    }
} else { "  (none registered in Security Center)" }
""
"--- Anti-spyware (Windows Security Center) ---"
$as = Get-CimInstance -Namespace root/SecurityCenter2 -ClassName AntiSpywareProduct -EA SilentlyContinue
if ($as) {
    $as | Sort-Object displayName | ForEach-Object {
        $state = $_.productState
        $enabled = ($state -band 0x1000) -ne 0
        "  $($_.displayName) — Enabled: $enabled | GUID: $($_.instanceGuid)"
    }
} else { "  (none registered in Security Center)" }
""
"--- Firewall (Windows Security Center) ---"
$fw = Get-CimInstance -Namespace root/SecurityCenter2 -ClassName FirewallProduct -EA SilentlyContinue
if ($fw) {
    $fw | Sort-Object displayName | ForEach-Object {
        $state = $_.productState
        $enabled = ($state -band 0x1000) -ne 0
        "  $($_.displayName) — Enabled: $enabled | GUID: $($_.instanceGuid)"
    }
} else { "  (none registered, default Windows firewall)" }
""
"--- Windows Defender ---"
$wdPrefs = Get-MpPreference -EA SilentlyContinue
if ($wdPrefs) {
    $wdStatus = Get-MpComputerStatus -EA SilentlyContinue
    "  RealTimeProtection : $($wdStatus.RealTimeProtectionEnabled)"
    "  AntivirusEnabled   : $($wdStatus.AntivirusEnabled)"
    "  SignatureDate      : $($wdStatus.AntivirusSignatureLastUpdated)"
    "  AMRunningMode      : $($wdStatus.AMRunningMode)"
} else { "  Windows Defender : information not available" }
"#;
    section("SECURITY TOOLS (Antivirus / Antimalware / Firewall)", ps(commands, script))
}

fn section_firewall_profiles(commands: &mut dyn CommandRunner) -> DiagSection {
    let script = r#"
$ErrorActionPreference='SilentlyContinue'
Get-NetFirewallProfile -EA SilentlyContinue | Sort-Object Name | ForEach-Object {
    "$($_.Name)"
    "  Enabled           : $($_.Enabled)"
    "  Inbound action    : $($_.DefaultInboundAction)"
    "  Outbound action   : $($_.DefaultOutboundAction)"
    "  Notification      : $($_.NotifyOnListen)"
    "  Log (blocked)     : $($_.LogBlocked)"
    ""
}
"#;
    section("FIREWALL (Domain / Private / Public profiles)", ps(commands, script))
}

fn section_processes(processes: &dyn ProcessManager, commands: &mut dyn CommandRunner) -> DiagSection {
    // PowerShell gives MD5 + SHA256 + signature + metadata + ACL warning.
    // Falls back to the plain ProcessManager list if PowerShell returns nothing.
    let script = r#"
$ErrorActionPreference='SilentlyContinue'
function Get-FileData($p) {
    if (!$p -or !(Test-Path $p)) { return $null }
    $fi = Get-Item $p
    $md5  = (Get-FileHash $p -Algorithm MD5).Hash
    $sha2 = (Get-FileHash $p -Algorithm SHA256).Hash
    $sig  = (Get-AuthenticodeSignature $p).Status
    $vi   = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($p)
    $acl  = Get-Acl $p
    $writable = $acl.Access | Where-Object {
        $_.FileSystemRights -match 'Write|FullControl' -and
        $_.IdentityReference -notmatch 'SYSTEM|Administrators|TrustedInstaller|CREATEUR|CREATOR'
    }
    [PSCustomObject]@{
        MD5      = $md5
        SHA256   = $sha2
        Sig      = $sig
        Size     = $fi.Length
        Created  = $fi.CreationTime.ToString('yyyy-MM-dd HH:mm')
        Modified = $fi.LastWriteTime.ToString('yyyy-MM-dd HH:mm')
        Company  = $vi.CompanyName
        FileVer  = $vi.FileVersion
        AclWarn  = if ($writable) { ($writable | ForEach-Object { "$($_.IdentityReference):$($_.FileSystemRights)" }) -join '; ' } else { $null }
    }
}
Get-Process | Sort-Object Name,Id | ForEach-Object {
    $path = $null
    try { $path = $_.MainModule.FileName } catch {}
    "[$($_.Id)] $($_.Name) — $(if($path){$path}else{'(path unavailable)'})"
    if ($path) {
        $d = Get-FileData $path
        if ($d) {
            "    MD5    : $($d.MD5)"
            "    SHA256 : $($d.SHA256)"
            "    Sig    : $($d.Sig) | Publisher: $($d.Company) | Ver: $($d.FileVer)"
            "    Size   : $($d.Size) bytes | Created: $($d.Created) | Modified: $($d.Modified)"
            if ($d.AclWarn) { "    !! ACL : $($d.AclWarn)" }
        }
    }
}
"#;
    let ps_lines = ps(commands, script);
    if !ps_lines.is_empty() {
        return section("RUNNING PROCESSES", ps_lines);
    }
    // Fallback: ProcessManager (for tests / environments without PowerShell)
    let list = processes.list();
    let count = list.len();
    let mut lines: Vec<String> = list
        .into_iter()
        .map(|p| match &p.exe_path {
            Some(path) => format!("[{}] {} — {}", p.pid, p.name, path),
            None => format!("[{}] {}", p.pid, p.name),
        })
        .collect();
    lines.sort();
    section(&format!("RUNNING PROCESSES ({count})"), lines)
}

fn section_services(commands: &mut dyn CommandRunner) -> DiagSection {
    let script = r#"
$ErrorActionPreference='SilentlyContinue'
function Get-FileData($p) {
    if (!$p -or !(Test-Path $p)) { return $null }
    $fi   = Get-Item $p
    $md5  = (Get-FileHash $p -Algorithm MD5).Hash
    $sha2 = (Get-FileHash $p -Algorithm SHA256).Hash
    $sig  = (Get-AuthenticodeSignature $p).Status
    $vi   = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($p)
    [PSCustomObject]@{
        MD5      = $md5; SHA256 = $sha2; Sig = $sig
        Size     = $fi.Length
        Modified = $fi.LastWriteTime.ToString('yyyy-MM-dd HH:mm')
        Company  = $vi.CompanyName; FileVer = $vi.FileVersion
    }
}
function Get-ExePath($raw) {
    if (!$raw) { return $null }
    if ($raw -match '^"([^"]+)"') { return $matches[1] }
    $t = ($raw -split ' ')[0]
    if (Test-Path $t -EA SilentlyContinue) { return $t }
    return $null
}
Get-CimInstance Win32_Service |
    Where-Object { $_.StartMode -in 'Auto','Manual' } |
    Sort-Object StartMode,Name |
    ForEach-Object {
        "[$($_.StartMode)/$($_.State)] $($_.Name) — $($_.DisplayName)"
        "    Path: $($_.PathName)"
        $exe = Get-ExePath $_.PathName
        if ($exe) {
            $d = Get-FileData $exe
            if ($d) {
                "    MD5    : $($d.MD5)"
                "    SHA256 : $($d.SHA256)"
                "    Sig    : $($d.Sig) | Publisher: $($d.Company) | Ver: $($d.FileVer)"
                "    Size   : $($d.Size) bytes | Modified: $($d.Modified)"
            }
        }
    }
"#;
    section("SERVICES (Automatic / Manual)", ps(commands, script))
}

fn section_drivers(commands: &mut dyn CommandRunner) -> DiagSection {
    // Kernel drivers are the classic rootkit persistence vector. Listing all
    // ~200 stock Windows drivers is noise, so this section gives a total
    // count and then details only the ones NOT signed by Microsoft — signed
    // third-party drivers (GPU, storage, security tools) plus anything
    // unsigned or tampered with, which is what actually warrants a look.
    let script = r#"
$ErrorActionPreference='SilentlyContinue'
function Resolve-DriverPath($raw) {
    if (!$raw) { return $null }
    if ($raw -match '^\\SystemRoot\\(.*)$') { return "$env:SystemRoot\$($matches[1])" }
    if ($raw -match '^\\\?\?\\(.*)$') { return $matches[1] }
    if ($raw -match '^[A-Za-z]:\\') { return $raw }
    return "$env:SystemRoot\System32\drivers\$raw"
}
function Get-FileData($p) {
    if (!$p -or !(Test-Path $p)) { return $null }
    $fi  = Get-Item $p
    $sig = Get-AuthenticodeSignature $p
    $vi  = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($p)
    [PSCustomObject]@{
        SHA256   = (Get-FileHash $p -Algorithm SHA256).Hash
        SigStatus= $sig.Status
        Signer   = if ($sig.SignerCertificate) { $sig.SignerCertificate.Subject } else { $null }
        Company  = $vi.CompanyName
        FileVer  = $vi.FileVersion
        Modified = $fi.LastWriteTime.ToString('yyyy-MM-dd HH:mm')
    }
}
$drivers = Get-CimInstance Win32_SystemDriver |
    Where-Object { $_.State -eq 'Running' -or $_.StartMode -in 'Boot','System','Auto' }
"Total active/automatic drivers : $($drivers.Count)"
""
"--- Drivers not signed by Microsoft (or unsigned) ---"
$suspect = foreach ($drv in $drivers) {
    $path = Resolve-DriverPath $drv.PathName
    $d = Get-FileData $path
    if (!($d -and $d.Company -match 'Microsoft')) {
        [PSCustomObject]@{ Drv = $drv; Path = $path; Data = $d }
    }
}
if (!$suspect) { "  (none — every active driver is signed by Microsoft)" }
foreach ($s in $suspect) {
    $drv = $s.Drv
    $d = $s.Data
    "  [$($drv.State)/$($drv.StartMode)] $($drv.Name) — $($drv.DisplayName)"
    if ($s.Path) { "    Path      : $($s.Path)" }
    if ($d) {
        $signer = if ($d.Signer) { " — $($d.Signer)" } else { "" }
        "    Signature : $($d.SigStatus)$signer"
        "    Publisher : $($d.Company) | Ver: $($d.FileVer) | Modified: $($d.Modified)"
        "    SHA256    : $($d.SHA256)"
    } else {
        "    (file not found or inaccessible)"
    }
}
"#;
    section(
        "DRIVERS (non-Microsoft highlighted)",
        ps(commands, script),
    )
}

fn section_startup(commands: &mut dyn CommandRunner) -> DiagSection {
    let script = r#"
$ErrorActionPreference='SilentlyContinue'
function Get-FileData($p) {
    if (!$p -or !(Test-Path $p)) { return $null }
    $fi   = Get-Item $p
    $md5  = (Get-FileHash $p -Algorithm MD5).Hash
    $sha2 = (Get-FileHash $p -Algorithm SHA256).Hash
    $sig  = (Get-AuthenticodeSignature $p).Status
    $vi   = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($p)
    $acl  = Get-Acl $p
    $writable = $acl.Access | Where-Object {
        $_.FileSystemRights -match 'Write|FullControl' -and
        $_.IdentityReference -notmatch 'SYSTEM|Administrators|TrustedInstaller|CREATEUR|CREATOR'
    }
    [PSCustomObject]@{
        MD5      = $md5; SHA256 = $sha2; Sig = $sig
        Size     = $fi.Length
        Created  = $fi.CreationTime.ToString('yyyy-MM-dd HH:mm')
        Modified = $fi.LastWriteTime.ToString('yyyy-MM-dd HH:mm')
        Company  = $vi.CompanyName; FileVer = $vi.FileVersion
        AclWarn  = if ($writable) { ($writable | ForEach-Object { "$($_.IdentityReference):$($_.FileSystemRights)" }) -join '; ' } else { $null }
    }
}
function Get-ExeFromValue($val) {
    if ($val -match '^"([^"]+\.exe)"') { return $matches[1] }
    if ($val -match '^([^\s"]+\.exe)') { return $matches[1] }
    return $null
}
$keys = @(
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run',
    'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run',
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce',
    'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce',
    'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run'
)
foreach ($k in $keys) {
    $props = Get-ItemProperty $k -EA SilentlyContinue
    if ($props) {
        $hive = if ($k -match 'HKLM') {'HKLM'} else {'HKCU'}
        $sub  = $k -replace '.*CurrentVersion\\',''
        $props.PSObject.Properties | Where-Object {$_.Name -notlike 'PS*'} | ForEach-Object {
            "[$hive\$sub] $($_.Name) = $($_.Value)"
            $exe = Get-ExeFromValue $_.Value
            if ($exe) {
                $d = Get-FileData $exe
                if ($d) {
                    "    MD5    : $($d.MD5)"
                    "    SHA256 : $($d.SHA256)"
                    "    Sig    : $($d.Sig) | Publisher: $($d.Company) | Ver: $($d.FileVer)"
                    "    Size   : $($d.Size) bytes | Created: $($d.Created) | Modified: $($d.Modified)"
                    if ($d.AclWarn) { "    !! ACL : $($d.AclWarn)" }
                }
            }
        }
    }
}
"#;
    section("STARTUP (Run / RunOnce)", ps(commands, script))
}

fn section_scheduled_tasks(commands: &mut dyn CommandRunner) -> DiagSection {
    let script = r#"
$ErrorActionPreference='SilentlyContinue'
function Get-FileData($p) {
    if (!$p -or !(Test-Path $p)) { return $null }
    $md5  = (Get-FileHash $p -Algorithm MD5).Hash
    $sha2 = (Get-FileHash $p -Algorithm SHA256).Hash
    $sig  = (Get-AuthenticodeSignature $p).Status
    $vi   = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($p)
    "MD5:$md5 | SHA256:$sha2 | Sig:$sig | Publisher:$($vi.CompanyName)"
}
Get-ScheduledTask -EA SilentlyContinue |
    Where-Object { $_.TaskPath -notlike '\Microsoft\*' } |
    Sort-Object TaskPath,TaskName |
    ForEach-Object {
        $task = $_
        "[$($task.State)] $($task.TaskPath)$($task.TaskName)"
        $task.Actions | ForEach-Object {
            if ($_.Execute) {
                "    Execute : $($_.Execute) $($_.Arguments)"
                $d = Get-FileData $_.Execute
                if ($d) { "    $d" }
            }
            if ($_.WorkingDirectory) { "    WorkDir : $($_.WorkingDirectory)" }
        }
        $trigger = ($task.Triggers | ForEach-Object {$_.GetType().Name -replace 'Trigger',''}) -join ', '
        if ($trigger) { "    Trigger : $trigger" }
        $principal = $task.Principal
        "    RunAs   : $($principal.UserId) ($($principal.RunLevel))"
    }
"#;
    section("SCHEDULED TASKS (excluding Microsoft)", ps(commands, script))
}

fn section_installed_software(commands: &mut dyn CommandRunner) -> DiagSection {
    let script = r#"
$ErrorActionPreference='SilentlyContinue'
$paths = @(
    'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
)
Get-ItemProperty $paths -EA SilentlyContinue |
    Where-Object { $_.DisplayName -and $_.DisplayName.Trim() } |
    Sort-Object DisplayName |
    ForEach-Object {
        "$($_.DisplayName) $($_.DisplayVersion) — $($_.Publisher)"
        if ($_.InstallDate) {
            $d = $_.InstallDate
            if ($d -match '(\d{4})(\d{2})(\d{2})') { "    Installed on : $($matches[1])-$($matches[2])-$($matches[3])" }
        }
        if ($_.InstallLocation) { "    Folder       : $($_.InstallLocation)" }
        if ($_.UninstallString) { "    Uninstall    : $($_.UninstallString)" }
    }
"#;
    section("INSTALLED SOFTWARE", ps(commands, script))
}

fn section_browser_extensions(commands: &mut dyn CommandRunner) -> DiagSection {
    let script = r#"
$ErrorActionPreference='SilentlyContinue'
# ── Chrome ────────────────────────────────────────────────────────────────────
"--- Google Chrome ---"
$chromeBase = "$env:LOCALAPPDATA\Google\Chrome\User Data"
if (Test-Path $chromeBase) {
    Get-ChildItem "$chromeBase" -Directory | Where-Object { $_.Name -like 'Profile*' -or $_.Name -eq 'Default' } | ForEach-Object {
        $profile = $_.Name
        $extDir = "$chromeBase\$profile\Extensions"
        if (Test-Path $extDir) {
            Get-ChildItem $extDir -Directory -EA SilentlyContinue | ForEach-Object {
                $extId = $_.Name
                $verDir = Get-ChildItem $_.FullName -Directory -EA SilentlyContinue | Sort-Object Name -Descending | Select-Object -First 1
                if ($verDir) {
                    $manifest = "$($verDir.FullName)\manifest.json"
                    if (Test-Path $manifest) {
                        $m = Get-Content $manifest -Raw -EA SilentlyContinue | ConvertFrom-Json -EA SilentlyContinue
                        $name = if ($m.name -and !($m.name -like '__MSG_*')) { $m.name } else { "(localized name)" }
                        "  [$profile] $extId — $name v$($m.version)"
                        if ($m.permissions) { "    Permissions: $($m.permissions -join ', ')" }
                    }
                }
            }
        }
    }
} else { "  (Chrome not installed or profile not found)" }
""
# ── Microsoft Edge ────────────────────────────────────────────────────────────
"--- Microsoft Edge ---"
$edgeBase = "$env:LOCALAPPDATA\Microsoft\Edge\User Data"
if (Test-Path $edgeBase) {
    Get-ChildItem "$edgeBase" -Directory | Where-Object { $_.Name -like 'Profile*' -or $_.Name -eq 'Default' } | ForEach-Object {
        $profile = $_.Name
        $extDir = "$edgeBase\$profile\Extensions"
        if (Test-Path $extDir) {
            Get-ChildItem $extDir -Directory -EA SilentlyContinue | ForEach-Object {
                $extId = $_.Name
                $verDir = Get-ChildItem $_.FullName -Directory -EA SilentlyContinue | Sort-Object Name -Descending | Select-Object -First 1
                if ($verDir) {
                    $manifest = "$($verDir.FullName)\manifest.json"
                    if (Test-Path $manifest) {
                        $m = Get-Content $manifest -Raw -EA SilentlyContinue | ConvertFrom-Json -EA SilentlyContinue
                        $name = if ($m.name -and !($m.name -like '__MSG_*')) { $m.name } else { "(localized name)" }
                        "  [$profile] $extId — $name v$($m.version)"
                        if ($m.permissions) { "    Permissions: $($m.permissions -join ', ')" }
                    }
                }
            }
        }
    }
} else { "  (Edge not installed or profile not found)" }
""
# ── Firefox ───────────────────────────────────────────────────────────────────
"--- Mozilla Firefox ---"
$ffBase = "$env:APPDATA\Mozilla\Firefox\Profiles"
if (Test-Path $ffBase) {
    Get-ChildItem $ffBase -Directory -EA SilentlyContinue | ForEach-Object {
        $profileDir = $_.FullName
        $addonsJson = "$profileDir\extensions.json"
        if (Test-Path $addonsJson) {
            $data = Get-Content $addonsJson -Raw -EA SilentlyContinue | ConvertFrom-Json -EA SilentlyContinue
            if ($data -and $data.addons) {
                $data.addons | Where-Object { $_.type -eq 'extension' -and $_.id -notlike '*mozilla*' -and $_.id -notlike '*firefox*' } | ForEach-Object {
                    "  [$($_.defaultLocale.name)] ID: $($_.id) v$($_.version) — Active: $($_.active)"
                    if ($_.userPermissions -and $_.userPermissions.permissions) {
                        "    Permissions: $($_.userPermissions.permissions -join ', ')"
                    }
                }
            }
        }
    }
} else { "  (Firefox not installed or profile not found)" }
"#;
    section("BROWSER EXTENSIONS (Chrome / Edge / Firefox)", ps(commands, script))
}

fn section_recent_files(commands: &mut dyn CommandRunner) -> DiagSection {
    let script = r#"
$ErrorActionPreference='SilentlyContinue'
$cutoff = (Get-Date).AddDays(-90)
$dirs = @(
    "$env:USERPROFILE\Downloads",
    "$env:USERPROFILE\Desktop",
    "$env:TEMP",
    "C:\Windows\Temp",
    "$env:LOCALAPPDATA\Temp",
    "$env:APPDATA\Microsoft\Windows\Recent",
    "$env:USERPROFILE\AppData\Local\Microsoft\Windows\INetCache"
)
foreach ($d in $dirs) {
    if (!(Test-Path $d -EA SilentlyContinue)) { continue }
    $files = Get-ChildItem $d -File -Recurse -EA SilentlyContinue |
        Where-Object { $_.LastWriteTime -gt $cutoff } |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 100
    if ($files) {
        "--- $d ---"
        $files | ForEach-Object {
            $f = $_
            $ext = $f.Extension.ToLower()
            $flag = if ($ext -in @('.exe','.dll','.bat','.cmd','.vbs','.js','.ps1','.scr','.com','.pif','.msi','.jar','.hta')) {
                ' [EXE/SCRIPT]'
            } elseif ($ext -in @('.zip','.rar','.7z','.tar','.gz')) {
                ' [ARCHIVE]'
            } else { '' }
            "$($f.LastWriteTime.ToString('yyyy-MM-dd HH:mm')) $($f.Length.ToString().PadLeft(12)) $($f.FullName)$flag"
        }
        ""
    }
}
"#;
    section("RECENT FILES (last 90 days)", ps(commands, script))
}

fn section_hosts_file(commands: &mut dyn CommandRunner, dirs: &dyn KnownDirs) -> DiagSection {
    let hosts = format!("{}\\System32\\drivers\\etc\\hosts", dirs.windows_dir());
    let script = format!(
        r#"
$ErrorActionPreference='SilentlyContinue'
$p = '{hosts}'
if (Test-Path $p) {{
    $md5  = (Get-FileHash $p -Algorithm MD5).Hash
    $sha2 = (Get-FileHash $p -Algorithm SHA256).Hash
    $fi   = Get-Item $p
    "File    : $p"
    "MD5     : $md5"
    "SHA256  : $sha2"
    "Size    : $($fi.Length) bytes | Modified: $($fi.LastWriteTime.ToString('yyyy-MM-dd HH:mm'))"
    "--- Active entries (excluding comments) ---"
    Get-Content $p | Where-Object {{ $_ -notmatch '^\s*#' -and $_ -match '\S' }}
}} else {{ "Hosts file not found: $p" }}
"#,
        hosts = hosts
    );
    section("HOSTS FILE", ps(commands, &script))
}

fn section_network(commands: &mut dyn CommandRunner) -> DiagSection {
    let lines = commands
        .run_capture("ipconfig.exe", &["/all"])
        .unwrap_or_default()
        .lines()
        .map(str::to_string)
        .filter(|l| !l.trim().is_empty())
        .collect();
    section("NETWORK CONFIGURATION (ipconfig /all)", lines)
}

fn section_winsock_catalog(commands: &mut dyn CommandRunner) -> DiagSection {
    // Raw provider catalog: each entry that isn't a stock Windows provider
    // (loaded from a DLL outside System32) is where a network-layer hijack
    // (rogue LSP) would show up. Dumped as-is, like `ipconfig /all` above —
    // no filtering, so nothing that matters is left out.
    let lines = commands
        .run_capture("netsh.exe", &["winsock", "show", "catalog"])
        .unwrap_or_default()
        .lines()
        .map(str::to_string)
        .filter(|l| !l.trim().is_empty())
        .collect();
    section("WINSOCK CATALOG (netsh winsock show catalog)", lines)
}

fn section_proxy(commands: &mut dyn CommandRunner) -> DiagSection {
    let script = r#"
$ErrorActionPreference='SilentlyContinue'
$k = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings'
$p = Get-ItemProperty $k
"--- HKCU Internet Settings ---"
"ProxyEnable   : $($p.ProxyEnable)"
"ProxyServer   : $($p.ProxyServer)"
"AutoConfigURL : $($p.AutoConfigURL)"
"ProxyOverride : $($p.ProxyOverride)"
"--- HKLM Internet Settings ---"
$pm = Get-ItemProperty 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -EA SilentlyContinue
"ProxyEnable   : $($pm.ProxyEnable)"
"ProxyServer   : $($pm.ProxyServer)"
"--- WinHTTP ---"
netsh winhttp show proxy 2>&1
"--- Environment variables ---"
"HTTP_PROXY    : $env:HTTP_PROXY"
"HTTPS_PROXY   : $env:HTTPS_PROXY"
"NO_PROXY      : $env:NO_PROXY"
"#;
    section("SYSTEM PROXY", ps(commands, script))
}

fn section_browser_policies(commands: &mut dyn CommandRunner) -> DiagSection {
    // Dumps the actual value names/data under each browser Group Policy key
    // (and one level of subkeys, e.g. ExtensionInstallForcelist) instead of
    // just flagging the key as present — a policy key present with an empty
    // homepage/search override reads very differently from one that force-
    // installs three extensions and locks the search engine.
    let script = r#"
$ErrorActionPreference='SilentlyContinue'
function Dump-PolicyKey($path, $label) {
    "--- $label ---"
    if (!(Test-Path $path)) { "  (absent)"; ""; return }
    $item = Get-Item $path
    foreach ($p in $item.Property) {
        $v = (Get-ItemProperty -Path $path -Name $p -EA SilentlyContinue).$p
        "  $p = $v"
    }
    $subkeys = Get-ChildItem $path -EA SilentlyContinue
    foreach ($sub in $subkeys) {
        "  [$($sub.PSChildName)]"
        foreach ($p in $sub.Property) {
            $v = (Get-ItemProperty -Path $sub.PSPath -Name $p -EA SilentlyContinue).$p
            "    $p = $v"
        }
    }
    if (!$item.Property -and !$subkeys) { "  (key present, no values)" }
    ""
}
Dump-PolicyKey 'HKLM:\SOFTWARE\Policies\Google\Chrome'   'Chrome   (HKLM)'
Dump-PolicyKey 'HKCU:\SOFTWARE\Policies\Google\Chrome'   'Chrome   (HKCU)'
Dump-PolicyKey 'HKLM:\SOFTWARE\Policies\Microsoft\Edge'  'Edge     (HKLM)'
Dump-PolicyKey 'HKCU:\SOFTWARE\Policies\Microsoft\Edge'  'Edge     (HKCU)'
Dump-PolicyKey 'HKLM:\SOFTWARE\Policies\Mozilla\Firefox' 'Firefox  (HKLM)'
Dump-PolicyKey 'HKCU:\SOFTWARE\Policies\Mozilla\Firefox' 'Firefox  (HKCU)'
"#;
    section("BROWSER POLICIES (Policies)", ps(commands, script))
}

fn section_file_associations(commands: &mut dyn CommandRunner) -> DiagSection {
    // Current HKCR ProgId + shell\open\command, and any per-user UserChoice
    // override, for the same four extensions "Restore file associations"
    // resets. The Windows-standard ProgId/command is printed next
    // to the live value purely as a reference point — this file never
    // labels an entry as wrong or in need of repair.
    let script = r#"
$ErrorActionPreference='SilentlyContinue'
New-PSDrive -PSProvider Registry -Root HKEY_CLASSES_ROOT -Name HKCR -EA SilentlyContinue | Out-Null
$refs = [ordered]@{
    '.exe' = @{ ProgId='exefile'; Cmd='"%1" %*' }
    '.bat' = @{ ProgId='batfile'; Cmd='"%1" %*' }
    '.com' = @{ ProgId='comfile'; Cmd='"%1" %*' }
    '.lnk' = @{ ProgId='lnkfile'; Cmd='(handled by the shell, no explicit command)' }
}
foreach ($ext in $refs.Keys) {
    $progId = (Get-ItemProperty "HKCR:\$ext" -EA SilentlyContinue).'(default)'
    "$ext"
    "  ProgId (HKCR)         : $(if($progId){$progId}else{'(none)'})"
    if ($progId) {
        $cmd = (Get-ItemProperty "HKCR:\$progId\shell\open\command" -EA SilentlyContinue).'(default)'
        "  Command (shell/open)  : $(if($cmd){$cmd}else{'(none)'})"
    }
    $userChoiceKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\$ext\UserChoice"
    $userChoice = (Get-ItemProperty $userChoiceKey -EA SilentlyContinue).ProgId
    "  UserChoice (HKCU)     : $(if($userChoice){$userChoice}else{'(none)'})"
    "  Windows reference     : ProgId '$($refs[$ext].ProgId)', command $($refs[$ext].Cmd)"
    ""
}
"#;
    section(
        "FILE ASSOCIATIONS (.exe / .bat / .com / .lnk)",
        ps(commands, script),
    )
}

fn section_explorer_settings(commands: &mut dyn CommandRunner) -> DiagSection {
    // The three Explorer display values "Restore system settings"
    // resets. Each line states the value's documented meaning and Windows'
    // own default next to the live value, as reference — not a verdict.
    let script = r#"
$ErrorActionPreference='SilentlyContinue'
$p = Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -EA SilentlyContinue
"Hidden          : $($p.Hidden)  (2 = hidden files/folders not shown [Windows default] ; 1 = shown)"
"HideFileExt     : $($p.HideFileExt)  (1 = known file extensions hidden [Windows default] ; 0 = shown)"
"ShowSuperHidden : $($p.ShowSuperHidden)  (0 = protected system files hidden [Windows default] ; 1 = shown)"
"#;
    section(
        "EXPLORER SETTINGS (hidden files / extensions)",
        ps(commands, script),
    )
}

// ── Tests ─────────────────────────────────────────────────────────────────────

#[cfg(test)]
mod tests {
    use super::*;
    use crate::fakes::{FakeCommandRunner, FakeKnownDirs, FakeProcessManager};

    #[test]
    fn collect_returns_twenty_sections() {
        let processes = FakeProcessManager::new();
        let mut commands = FakeCommandRunner::new();
        let dirs = FakeKnownDirs::default();
        let report = collect(&processes, &mut commands, &dirs, "2024-01-01 00:00:00");
        assert_eq!(report.sections.len(), 20);
    }

    #[test]
    fn to_text_starts_with_utf8_bom() {
        let processes = FakeProcessManager::new();
        let mut commands = FakeCommandRunner::new();
        let dirs = FakeKnownDirs::default();
        let report = collect(&processes, &mut commands, &dirs, "2024-01-01 00:00:00");
        let text = report.to_text();
        assert!(text.starts_with('\u{FEFF}'), "Report must begin with UTF-8 BOM");
    }

    #[test]
    fn to_text_contains_header_and_all_section_titles() {
        let processes = FakeProcessManager::new();
        let mut commands = FakeCommandRunner::new();
        let dirs = FakeKnownDirs::default();
        let report = collect(&processes, &mut commands, &dirs, "2024-01-01 00:00:00");
        let text = report.to_text();
        assert!(text.contains("KpRm"));
        assert!(text.contains("WINDOWS ACTIVATION"));
        assert!(text.contains("SYSTEM INFORMATION"));
        assert!(text.contains("WINDOWS ERRORS"));
        assert!(text.contains("SECURITY TOOLS"));
        assert!(text.contains("FIREWALL"));
        assert!(text.contains("RUNNING PROCESSES"));
        assert!(text.contains("SERVICES"));
        assert!(text.contains("DRIVERS"));
        assert!(text.contains("STARTUP"));
        assert!(text.contains("SCHEDULED TASKS"));
        assert!(text.contains("INSTALLED SOFTWARE"));
        assert!(text.contains("BROWSER EXTENSIONS"));
        assert!(text.contains("RECENT FILES"));
        assert!(text.contains("HOSTS FILE"));
        assert!(text.contains("NETWORK CONFIGURATION"));
        assert!(text.contains("WINSOCK CATALOG"));
        assert!(text.contains("SYSTEM PROXY"));
        assert!(text.contains("BROWSER POLICIES"));
        assert!(text.contains("FILE ASSOCIATIONS"));
        assert!(text.contains("EXPLORER SETTINGS"));
    }

    #[test]
    fn processes_falls_back_to_process_manager_when_powershell_unavailable() {
        let processes = {
            let mut p = FakeProcessManager::new();
            p.add(1234, "chrome.exe", Some(r"C:\Program Files\Google\Chrome\Application\chrome.exe"));
            p.add(42, "explorer.exe", None);
            p
        };
        let mut commands = FakeCommandRunner::new();
        commands.captured_stdout = None;
        let sec = section_processes(&processes, &mut commands);
        assert!(sec.lines.iter().any(|l| l.contains("chrome.exe")));
        assert!(sec.lines.iter().any(|l| l.contains("explorer.exe")));
    }

    #[test]
    fn browser_policies_section_calls_powershell_for_every_browser_key() {
        let mut commands = FakeCommandRunner::new();
        section_browser_policies(&mut commands);
        assert!(commands.calls.iter().any(|(p, a)| {
            p == "powershell.exe"
                && a.iter().any(|s| {
                    s.contains(r"Policies\Google\Chrome")
                        && s.contains(r"Policies\Microsoft\Edge")
                        && s.contains(r"Policies\Mozilla\Firefox")
                })
        }));
    }

    #[test]
    fn file_associations_section_calls_powershell_with_the_four_extensions() {
        let mut commands = FakeCommandRunner::new();
        section_file_associations(&mut commands);
        assert!(commands.calls.iter().any(|(p, a)| {
            p == "powershell.exe"
                && a.iter().any(|s| {
                    s.contains(".exe") && s.contains(".bat") && s.contains(".com") && s.contains(".lnk")
                })
        }));
    }

    #[test]
    fn explorer_settings_section_calls_powershell_with_the_advanced_key() {
        let mut commands = FakeCommandRunner::new();
        section_explorer_settings(&mut commands);
        assert!(commands.calls.iter().any(|(p, a)| {
            p == "powershell.exe" && a.iter().any(|s| s.contains("Explorer\\Advanced"))
        }));
    }

    #[test]
    fn firewall_profiles_section_calls_powershell_with_get_netfirewallprofile() {
        let mut commands = FakeCommandRunner::new();
        section_firewall_profiles(&mut commands);
        assert!(commands.calls.iter().any(|(p, a)| {
            p == "powershell.exe" && a.iter().any(|s| s.contains("Get-NetFirewallProfile"))
        }));
    }

    #[test]
    fn winsock_catalog_section_calls_netsh_winsock_show_catalog() {
        let mut commands = FakeCommandRunner::new();
        section_winsock_catalog(&mut commands);
        assert!(commands.calls.iter().any(|(p, a)| {
            p == "netsh.exe" && a == &["winsock", "show", "catalog"]
        }));
    }

    #[test]
    fn drivers_section_calls_powershell_with_win32_systemdriver() {
        let mut commands = FakeCommandRunner::new();
        section_drivers(&mut commands);
        assert!(commands.calls.iter().any(|(p, a)| {
            p == "powershell.exe" && a.iter().any(|s| s.contains("Win32_SystemDriver"))
        }));
    }

    #[test]
    fn windows_events_section_calls_powershell_with_geteventlog() {
        let mut commands = FakeCommandRunner::new();
        section_windows_events(&mut commands);
        assert!(commands.calls.iter().any(|(p, a)| {
            p == "powershell.exe" && a.iter().any(|s| s.contains("Get-WinEvent"))
        }));
    }

    #[test]
    fn hosts_section_calls_powershell_with_windows_path() {
        let mut commands = FakeCommandRunner::new();
        let dirs = FakeKnownDirs::default();
        section_hosts_file(&mut commands, &dirs);
        assert!(commands.calls.iter().any(|(p, a)| {
            p == "powershell.exe" && a.iter().any(|s| s.contains("hosts"))
        }));
    }

    #[test]
    fn empty_sections_render_as_no_entry_placeholder() {
        let sec = DiagSection { title: "TEST".into(), lines: vec![] };
        let report = DiagnosticReport {
            generated_at: "2024-01-01".into(),
            sections: vec![sec],
        };
        let text = report.to_text();
        assert!(text.contains("(no entries)"));
    }
}
