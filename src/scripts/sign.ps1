<#
.SYNOPSIS
    Authenticode-signs the release kprm.exe with a local .pfx certificate.

.DESCRIPTION
    Wraps `signtool.exe sign` the same way it's always been run by hand —
    this just avoids retyping the full command, and keeps the certificate
    and its password out of shell history / this repo entirely. Neither
    is ever read from a file in the repo: both come from environment
    variables, explicit parameters, or an interactive prompt, always at
    run time, on your own machine.

    Needs nothing from this repo except the built exe. In particular:
    DO NOT commit the .pfx anywhere under this repository.

.PARAMETER PfxPath
    Path to the .pfx certificate. Defaults to $env:KPRM_PFX_PATH.

.PARAMETER PfxPassword
    The .pfx's password, as a SecureString. Defaults to
    $env:KPRM_PFX_PASSWORD if set, otherwise you're prompted (input
    hidden) — the env var is the less safe of the two, since any process
    running as you can read your environment; prefer the prompt on a
    machine you don't fully trust.

.PARAMETER ExePath
    The file to sign. Defaults to <repo>\src\target\release\kprm.exe.

.PARAMETER SignToolPath
    Path to signtool.exe. Defaults to $env:KPRM_SIGNTOOL_PATH, falling
    back to the newest one found under the installed Windows SDK.

.PARAMETER TimestampUrl
    Authenticode timestamp server. Defaults to DigiCert's, matching what
    was used by hand before.

.PARAMETER DigestAlgorithm
    File digest algorithm (signtool's /fd). Current signtool builds
    refuse to sign at all without this specified; SHA256 is the current
    recommendation (SHA1 was the old implicit default).

.EXAMPLE
    $env:KPRM_PFX_PATH = 'C:\Users\IEUser\Desktop\sign\kernel-panik.pfx'
    cargo build --release -p kprm
    .\src\scripts\sign.ps1
    # prompts for the PFX password, signs src\target\release\kprm.exe

.EXAMPLE
    .\src\scripts\sign.ps1 -PfxPath 'D:\certs\kernel-panik.pfx'
#>
[CmdletBinding()]
param(
    [string]$PfxPath = $env:KPRM_PFX_PATH,
    [System.Security.SecureString]$PfxPassword,
    [string]$ExePath,
    [string]$SignToolPath = $env:KPRM_SIGNTOOL_PATH,
    [string]$TimestampUrl = 'http://timestamp.digicert.com',
    [string]$DigestAlgorithm = 'sha256'
)

$ErrorActionPreference = 'Stop'

# This script lives at <repo>\src\scripts\sign.ps1.
$repoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if (-not $ExePath) {
    $ExePath = Join-Path $repoRoot 'src\target\release\kprm.exe'
}

if (-not (Test-Path -LiteralPath $ExePath)) {
    throw "Executable not found: $ExePath`nBuild it first: cargo build --release -p kprm"
}

if (-not $PfxPath) {
    throw "No .pfx path given. Pass -PfxPath, or set `$env:KPRM_PFX_PATH` to its location on this machine (never commit this file)."
}
if (-not (Test-Path -LiteralPath $PfxPath)) {
    throw "PFX not found: $PfxPath"
}

if (-not $PfxPassword) {
    if ($env:KPRM_PFX_PASSWORD) {
        $PfxPassword = ConvertTo-SecureString -String $env:KPRM_PFX_PASSWORD -AsPlainText -Force
    } else {
        $PfxPassword = Read-Host -Prompt "PFX password for $PfxPath" -AsSecureString
    }
}
# signtool's own CLI only ever accepts the password as plain text (/p) —
# there's no way around that without switching to a certificate-store +
# thumbprint flow instead of a loose .pfx file. This converts only right
# before the call and the variable is cleared immediately after.
$plainPassword = [System.Net.NetworkCredential]::new('', $PfxPassword).Password

if (-not $SignToolPath) {
    $kitsBin = "${env:ProgramFiles(x86)}\Windows Kits\10\bin"
    $candidates = Get-ChildItem -LiteralPath $kitsBin -Filter 'signtool.exe' -Recurse -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -like '*\x64\*' } |
        Sort-Object FullName -Descending
    if ($candidates) { $SignToolPath = $candidates[0].FullName }
}
if (-not $SignToolPath -or -not (Test-Path -LiteralPath $SignToolPath)) {
    throw "signtool.exe not found. Install the Windows SDK, or pass -SignToolPath / set `$env:KPRM_SIGNTOOL_PATH."
}

Write-Host "Signing $ExePath"
Write-Host "  cert      : $PfxPath"
Write-Host "  signtool  : $SignToolPath"
Write-Host "  timestamp : $TimestampUrl"
Write-Host "  digest    : $DigestAlgorithm"

try {
    & $SignToolPath sign /fd $DigestAlgorithm /f $PfxPath /p $plainPassword /t $TimestampUrl $ExePath
    $exitCode = $LASTEXITCODE
} finally {
    $plainPassword = $null
    [System.GC]::Collect()
}

if ($exitCode -ne 0) {
    throw "signtool sign exited with code $exitCode"
}

& $SignToolPath verify /pa $ExePath
Write-Host "Signed and verified: $ExePath"
