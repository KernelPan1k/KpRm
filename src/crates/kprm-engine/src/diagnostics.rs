//! System diagnostic scanner — collects environment data and formats it as a
//! plain-text report that a technician can share on a support forum or keep
//! as a paper trail.
//!
//! Everything here is read-only: no files are modified, no registry keys are
//! written. Individual sections are gathered independently so a failure in one
//! (PowerShell unavailable, access denied) never aborts the whole scan.

use crate::paths::KnownDirs;
use crate::ports::{CommandRunner, ProcessManager, Registry};

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
            "KpRm v{} — Rapport diagnostic — {}\n",
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
                out.push_str("(aucune entrée)\n");
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
    registry: &dyn Registry,
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
            section_security_tools(commands),
            section_processes(processes, commands),
            section_services(commands),
            section_startup(commands),
            section_scheduled_tasks(commands),
            section_installed_software(commands),
            section_browser_extensions(commands),
            section_recent_files(commands),
            section_hosts_file(commands, dirs),
            section_network(commands),
            section_proxy(commands),
            section_browser_policies(registry),
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
if (!$products) { "Impossible de récupérer les informations de licence."; return }
foreach ($s in $products) {
    $statusText = switch ($s.LicenseStatus) {
        0 { "[NON LICENCIÉ] Aucune licence valide détectée" }
        1 { "[ACTIVÉ] Licence valide" }
        2 { "[GRACE] Période de grâce initiale (OOB)" }
        3 { "[GRACE] Hors tolérance" }
        4 { "[SUSPECT] Activation non conforme détectée — KMS/crack probable" }
        5 { "[NOTIFICATION] Notification requise" }
        6 { "[GRACE ÉTENDUE] Période de grâce étendue" }
        default { "[INCONNU ($($s.LicenseStatus))]" }
    }
    "Produit      : $($s.Name)"
    "Statut       : $statusText"
    if ($s.Description) { "Description  : $($s.Description)" }
    # KMS indicators
    if ($s.DiscoveredKeyManagementServiceMachineName) {
        "KMS Server   : $($s.DiscoveredKeyManagementServiceMachineName):$($s.DiscoveredKeyManagementServiceMachinePort)"
        "⚠ Activation KMS détectée — vérifiez que ce serveur est légitime (entreprise/école) ou suspect (crack/outil tiers)"
    }
    if ($s.GracePeriodRemaining -gt 0) {
        $days = [math]::Round($s.GracePeriodRemaining / 1440, 1)
        "Grâce        : $days jour(s) restant(s)"
    }
    # Check for known illegitimate activation tools via running processes
    $suspectProcs = @('KMSAuto','KMSpico','AAct','MAS','AutoKMS','Re-Loader','KMS_VL_ALL')
    $found = Get-Process -EA SilentlyContinue | Where-Object {
        $name = $_.Name
        $suspectProcs | Where-Object { $name -like "*$_*" }
    }
    if ($found) {
        "⚠ Processus suspect détecté : $($found.Name -join ', ') — outil d'activation tiers actif"
    }
    ""
}
"#;
    section("ACTIVATION WINDOWS", ps(commands, script))
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
"CPU         : $($p.Name) ($($p.NumberOfCores) coeurs / $($p.NumberOfLogicalProcessors) threads)"
"RAM         : $([math]::Round($c.TotalPhysicalMemory/1GB,2)) Go"
"Machine     : $($c.Name)"
"Fabricant   : $($c.Manufacturer) — $($c.Model)"
"BIOS        : $($b.Manufacturer) $($b.SMBIOSBIOSVersion) ($($b.ReleaseDate.ToString('yyyy-MM-dd')))"
"Domaine     : $($c.Domain)"
"Utilisateur : $env:USERNAME ($env:USERDOMAIN)"
"Comptes locaux actifs : $($u -join ', ')"
"PowerShell  : $($PSVersionTable.PSVersion)"
"CLR         : $([System.Runtime.InteropServices.RuntimeEnvironment]::GetSystemVersion())"
"Secure Boot : $((Confirm-SecureBootUEFI -EA SilentlyContinue))"
"UAC         : $(try{(Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System).EnableLUA}catch{'N/A'})"
"#;
    section("INFORMATIONS SYSTÈME", ps(commands, script))
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
        "  $($_.displayName) — Actif: $enabled | A jour: $upToDate | GUID: $($_.instanceGuid)"
    }
} else { "  (aucun enregistré dans Security Center)" }
""
"--- Anti-spyware (Windows Security Center) ---"
$as = Get-CimInstance -Namespace root/SecurityCenter2 -ClassName AntiSpywareProduct -EA SilentlyContinue
if ($as) {
    $as | Sort-Object displayName | ForEach-Object {
        $state = $_.productState
        $enabled = ($state -band 0x1000) -ne 0
        "  $($_.displayName) — Actif: $enabled | GUID: $($_.instanceGuid)"
    }
} else { "  (aucun enregistré dans Security Center)" }
""
"--- Pare-feu (Windows Security Center) ---"
$fw = Get-CimInstance -Namespace root/SecurityCenter2 -ClassName FirewallProduct -EA SilentlyContinue
if ($fw) {
    $fw | Sort-Object displayName | ForEach-Object {
        $state = $_.productState
        $enabled = ($state -band 0x1000) -ne 0
        "  $($_.displayName) — Actif: $enabled | GUID: $($_.instanceGuid)"
    }
} else { "  (aucun enregistré, pare-feu Windows par défaut)" }
""
"--- Windows Defender ---"
$wdPrefs = Get-MpPreference -EA SilentlyContinue
if ($wdPrefs) {
    $wdStatus = Get-MpComputerStatus -EA SilentlyContinue
    "  RealTimeProtection : $($wdStatus.RealTimeProtectionEnabled)"
    "  AntivirusEnabled   : $($wdStatus.AntivirusEnabled)"
    "  SignatureDate      : $($wdStatus.AntivirusSignatureLastUpdated)"
    "  AMRunningMode      : $($wdStatus.AMRunningMode)"
} else { "  Windows Defender : information non disponible" }
"#;
    section("OUTILS DE SÉCURITÉ (Antivirus / Antimalware / Pare-feu)", ps(commands, script))
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
    "[$($_.Id)] $($_.Name) — $(if($path){$path}else{'(chemin inaccessible)'})"
    if ($path) {
        $d = Get-FileData $path
        if ($d) {
            "    MD5    : $($d.MD5)"
            "    SHA256 : $($d.SHA256)"
            "    Sig    : $($d.Sig) | Editeur: $($d.Company) | Ver: $($d.FileVer)"
            "    Taille : $($d.Size) octets | Cree: $($d.Created) | Modifie: $($d.Modified)"
            if ($d.AclWarn) { "    !! ACL : $($d.AclWarn)" }
        }
    }
}
"#;
    let ps_lines = ps(commands, script);
    if !ps_lines.is_empty() {
        return section("PROCESSUS EN COURS", ps_lines);
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
    section(&format!("PROCESSUS EN COURS ({count})"), lines)
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
                "    Sig    : $($d.Sig) | Editeur: $($d.Company) | Ver: $($d.FileVer)"
                "    Taille : $($d.Size) octets | Modifie: $($d.Modified)"
            }
        }
    }
"#;
    section("SERVICES (Auto / Manuel)", ps(commands, script))
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
                    "    Sig    : $($d.Sig) | Editeur: $($d.Company) | Ver: $($d.FileVer)"
                    "    Taille : $($d.Size) octets | Cree: $($d.Created) | Modifie: $($d.Modified)"
                    if ($d.AclWarn) { "    !! ACL : $($d.AclWarn)" }
                }
            }
        }
    }
}
"#;
    section("DEMARRAGE AUTOMATIQUE (Run / RunOnce)", ps(commands, script))
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
    "MD5:$md5 | SHA256:$sha2 | Sig:$sig | Editeur:$($vi.CompanyName)"
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
    section("TACHES PLANIFIEES (hors Microsoft)", ps(commands, script))
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
            if ($d -match '(\d{4})(\d{2})(\d{2})') { "    Installe le : $($matches[1])-$($matches[2])-$($matches[3])" }
        }
        if ($_.InstallLocation) { "    Dossier     : $($_.InstallLocation)" }
        if ($_.UninstallString) { "    Desinstall  : $($_.UninstallString)" }
    }
"#;
    section("LOGICIELS INSTALLES", ps(commands, script))
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
                        $name = if ($m.name -and !($m.name -like '__MSG_*')) { $m.name } else { "(nom localisé)" }
                        "  [$profile] $extId — $name v$($m.version)"
                        if ($m.permissions) { "    Permissions: $($m.permissions -join ', ')" }
                    }
                }
            }
        }
    }
} else { "  (Chrome non installé ou profil introuvable)" }
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
                        $name = if ($m.name -and !($m.name -like '__MSG_*')) { $m.name } else { "(nom localisé)" }
                        "  [$profile] $extId — $name v$($m.version)"
                        if ($m.permissions) { "    Permissions: $($m.permissions -join ', ')" }
                    }
                }
            }
        }
    }
} else { "  (Edge non installé ou profil introuvable)" }
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
                    "  [$($_.defaultLocale.name)] ID: $($_.id) v$($_.version) — Actif: $($_.active)"
                    if ($_.userPermissions -and $_.userPermissions.permissions) {
                        "    Permissions: $($_.userPermissions.permissions -join ', ')"
                    }
                }
            }
        }
    }
} else { "  (Firefox non installé ou profil introuvable)" }
"#;
    section("EXTENSIONS NAVIGATEUR (Chrome / Edge / Firefox)", ps(commands, script))
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
    section("FICHIERS RECENTS (90 derniers jours)", ps(commands, script))
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
    "Fichier : $p"
    "MD5     : $md5"
    "SHA256  : $sha2"
    "Taille  : $($fi.Length) octets | Modifie: $($fi.LastWriteTime.ToString('yyyy-MM-dd HH:mm'))"
    "--- Entrees actives (hors commentaires) ---"
    Get-Content $p | Where-Object {{ $_ -notmatch '^\s*#' -and $_ -match '\S' }}
}} else {{ "Fichier hosts introuvable : $p" }}
"#,
        hosts = hosts
    );
    section("FICHIER HOSTS", ps(commands, &script))
}

fn section_network(commands: &mut dyn CommandRunner) -> DiagSection {
    let lines = commands
        .run_capture("ipconfig.exe", &["/all"])
        .unwrap_or_default()
        .lines()
        .map(str::to_string)
        .filter(|l| !l.trim().is_empty())
        .collect();
    section("CONFIGURATION RESEAU (ipconfig /all)", lines)
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
"--- Variables d'environnement ---"
"HTTP_PROXY    : $env:HTTP_PROXY"
"HTTPS_PROXY   : $env:HTTPS_PROXY"
"NO_PROXY      : $env:NO_PROXY"
"#;
    section("PROXY SYSTEME", ps(commands, script))
}

fn section_browser_policies(registry: &dyn Registry) -> DiagSection {
    let checks: &[(&str, &str)] = &[
        (r"HKLM\SOFTWARE\Policies\Google\Chrome",   "Chrome   (HKLM)"),
        (r"HKCU\SOFTWARE\Policies\Google\Chrome",   "Chrome   (HKCU)"),
        (r"HKLM\SOFTWARE\Policies\Microsoft\Edge",  "Edge     (HKLM)"),
        (r"HKCU\SOFTWARE\Policies\Microsoft\Edge",  "Edge     (HKCU)"),
        (r"HKLM\SOFTWARE\Policies\Mozilla\Firefox", "Firefox  (HKLM)"),
        (r"HKCU\SOFTWARE\Policies\Mozilla\Firefox", "Firefox  (HKCU)"),
    ];
    let lines: Vec<String> = checks
        .iter()
        .map(|(key, label)| {
            let present =
                registry.has_any_value(key) || !registry.enum_subkeys(key).is_empty();
            if present {
                format!("[PRESENT] {label} — {key}")
            } else {
                format!("[absent ] {label}")
            }
        })
        .collect();
    section("POLITIQUES NAVIGATEUR (Policies)", lines)
}

// ── Tests ─────────────────────────────────────────────────────────────────────

#[cfg(test)]
mod tests {
    use super::*;
    use crate::fakes::{FakeCommandRunner, FakeKnownDirs, FakeProcessManager, FakeRegistry};

    #[test]
    fn collect_returns_fourteen_sections() {
        let registry = FakeRegistry::new();
        let processes = FakeProcessManager::new();
        let mut commands = FakeCommandRunner::new();
        let dirs = FakeKnownDirs::default();
        let report = collect(&registry, &processes, &mut commands, &dirs, "2024-01-01 00:00:00");
        assert_eq!(report.sections.len(), 14);
    }

    #[test]
    fn to_text_starts_with_utf8_bom() {
        let registry = FakeRegistry::new();
        let processes = FakeProcessManager::new();
        let mut commands = FakeCommandRunner::new();
        let dirs = FakeKnownDirs::default();
        let report = collect(&registry, &processes, &mut commands, &dirs, "2024-01-01 00:00:00");
        let text = report.to_text();
        assert!(text.starts_with('\u{FEFF}'), "Report must begin with UTF-8 BOM");
    }

    #[test]
    fn to_text_contains_header_and_all_section_titles() {
        let registry = FakeRegistry::new();
        let processes = FakeProcessManager::new();
        let mut commands = FakeCommandRunner::new();
        let dirs = FakeKnownDirs::default();
        let report = collect(&registry, &processes, &mut commands, &dirs, "2024-01-01 00:00:00");
        let text = report.to_text();
        assert!(text.contains("KpRm"));
        assert!(text.contains("ACTIVATION WINDOWS"));
        assert!(text.contains("INFORMATIONS"));
        assert!(text.contains("OUTILS DE"));
        assert!(text.contains("PROCESSUS EN COURS"));
        assert!(text.contains("SERVICES"));
        assert!(text.contains("DEMARRAGE AUTOMATIQUE"));
        assert!(text.contains("TACHES PLANIFIEES"));
        assert!(text.contains("LOGICIELS INSTALLES"));
        assert!(text.contains("EXTENSIONS NAVIGATEUR"));
        assert!(text.contains("FICHIERS RECENTS"));
        assert!(text.contains("FICHIER HOSTS"));
        assert!(text.contains("CONFIGURATION RESEAU"));
        assert!(text.contains("PROXY SYSTEME"));
        assert!(text.contains("POLITIQUES NAVIGATEUR"));
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
    fn browser_policies_marks_present_keys() {
        let mut registry = FakeRegistry::new();
        registry.add_key(r"HKLM\SOFTWARE\Policies\Google\Chrome");
        registry.add_value(
            r"HKLM\SOFTWARE\Policies\Google\Chrome",
            "HomepageLocation",
            "http://evil.com",
        );
        let sec = section_browser_policies(&registry);
        let chrome = sec.lines.iter().find(|l| l.contains("Chrome") && l.contains("HKLM")).unwrap();
        assert!(chrome.contains("PRESENT"));
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
        assert!(text.contains("(aucune entrée)"));
    }
}
