#!/usr/bin/env bash
# Authenticode-signs the release kprm.exe with a local .pfx certificate.
# Bash counterpart of sign.ps1 — same environment variables, same
# defaults, same signtool.exe call. Needs nothing from this repo except
# the built exe: the certificate and its password always come from your
# own machine (env vars, flags, or a hidden prompt), never from a file
# in the repo. DO NOT commit the .pfx anywhere under this repository.
set -euo pipefail

usage() {
    cat <<'EOF'
Usage: sign.sh [-f PFX_PATH] [-p PFX_PASSWORD] [-e EXE_PATH] [-s SIGNTOOL_PATH] [-t TIMESTAMP_URL] [-d DIGEST_ALGORITHM]

Env var fallbacks: KPRM_PFX_PATH, KPRM_PFX_PASSWORD, KPRM_SIGNTOOL_PATH.
If -p/KPRM_PFX_PASSWORD is omitted, you're prompted (input hidden) — the
env var is the less safe of the two, since any process running as you
can read your environment; prefer the prompt on a machine you don't
fully trust.

Example:
  export KPRM_PFX_PATH='C:\Users\IEUser\Desktop\sign\kernel-panik.pfx'
  cargo build --release -p kprm
  ./src/scripts/sign.sh
EOF
}

pfx_path="${KPRM_PFX_PATH:-}"
pfx_password="${KPRM_PFX_PASSWORD:-}"
exe_path=""
signtool_path="${KPRM_SIGNTOOL_PATH:-}"
timestamp_url="http://timestamp.digicert.com"
# Current signtool builds refuse to sign at all without /fd specified;
# SHA256 is the current recommendation (SHA1 was the old implicit default).
digest_algorithm="sha256"

while getopts "f:p:e:s:t:d:h" opt; do
    case "$opt" in
        f) pfx_path="$OPTARG" ;;
        p) pfx_password="$OPTARG" ;;
        e) exe_path="$OPTARG" ;;
        s) signtool_path="$OPTARG" ;;
        t) timestamp_url="$OPTARG" ;;
        d) digest_algorithm="$OPTARG" ;;
        h) usage; exit 0 ;;
        *) usage; exit 1 ;;
    esac
done

# This script lives at <repo>/src/scripts/sign.sh.
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
exe_path="${exe_path:-$repo_root/src/target/release/kprm.exe}"

if [[ ! -f "$exe_path" ]]; then
    echo "Executable not found: $exe_path" >&2
    echo "Build it first: cargo build --release -p kprm" >&2
    exit 1
fi

if [[ -z "$pfx_path" ]]; then
    echo "No .pfx path given. Pass -f, or set KPRM_PFX_PATH to its location on this machine (never commit this file)." >&2
    exit 1
fi
if [[ ! -f "$pfx_path" ]]; then
    echo "PFX not found: $pfx_path" >&2
    exit 1
fi

if [[ -z "$pfx_password" ]]; then
    read -r -s -p "PFX password for $pfx_path: " pfx_password
    echo
fi

if [[ -z "$signtool_path" ]]; then
    signtool_path="$(find "/c/Program Files (x86)/Windows Kits/10/bin" -iname 'signtool.exe' -path '*/x64/*' 2>/dev/null | sort -r | head -n1)"
fi
if [[ -z "$signtool_path" || ! -f "$signtool_path" ]]; then
    echo "signtool.exe not found. Install the Windows SDK, or pass -s / set KPRM_SIGNTOOL_PATH." >&2
    exit 1
fi

echo "Signing $exe_path"
echo "  cert      : $pfx_path"
echo "  signtool  : $signtool_path"
echo "  timestamp : $timestamp_url"
echo "  digest    : $digest_algorithm"

# MSYS2_ARG_CONV_EXCL disables bash's automatic POSIX->Windows path
# conversion for every argument of this one call — without it, a leading
# "/f", "/p", "/t" here is mistaken for an absolute POSIX path and
# silently rewritten into garbage before signtool.exe ever sees it.
MSYS2_ARG_CONV_EXCL="*" "$signtool_path" sign /fd "$digest_algorithm" /f "$pfx_path" /p "$pfx_password" /t "$timestamp_url" "$exe_path"
unset pfx_password

MSYS2_ARG_CONV_EXCL="*" "$signtool_path" verify /pa "$exe_path"
echo "Signed and verified: $exe_path"
