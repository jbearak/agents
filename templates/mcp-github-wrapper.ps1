Param([Parameter(ValueFromRemainingArguments=$true)] [string[]]$Args)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Read GitHub token from Windows Credential Manager (Generic Credential: Target='GitHub')
try { Import-Module CredentialManager -ErrorAction Stop } catch { Write-Error 'Install CredentialManager: Install-Module CredentialManager -Scope CurrentUser'; exit 1 }
$cred = Get-StoredCredential -Target 'GitHub'
if (-not $cred) { Write-Error "Credential 'GitHub' not found"; exit 1 }
$env:GITHUB_PERSONAL_ACCESS_TOKEN = $cred.Password

# Prefer npm-installed CLI for fastest startup; fall back to npx, then container
$CLI_BIN = $env:MCP_GITHUB_CLI_BIN; if (-not $CLI_BIN) { $CLI_BIN = 'github-mcp-server' }
$NPM_PKG = $env:MCP_GITHUB_NPM_PKG; if (-not $NPM_PKG) { $NPM_PKG = 'github-mcp-server' }
$IMG     = $env:MCP_GITHUB_DOCKER_IMAGE; if (-not $IMG) { $IMG = 'ghcr.io/github/github-mcp-server:latest' }

function Invoke-Exec {
  param([string]$File,[string[]]$Arguments)
  & $File @Arguments
  if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

# 1) If CLI already available, run it
if (Get-Command $CLI_BIN -ErrorAction SilentlyContinue) {
  Invoke-Exec $CLI_BIN $Args
}

# 2) Try npx as a fallback (no global install)
if (Get-Command npx -ErrorAction SilentlyContinue) {
  Invoke-Exec 'npx' @('-y', $NPM_PKG) + $Args
}

# 3) Container fallback (prefer podman, else docker)
$runtime = if (Get-Command podman -ErrorAction SilentlyContinue) { 'podman' } elseif (Get-Command docker -ErrorAction SilentlyContinue) { 'docker' } else { $null }
if (-not $runtime) { Write-Error 'Neither podman nor docker found on PATH.'; exit 1 }
Invoke-Exec $runtime @('run','-i','--rm','--pull=never','-e',"GITHUB_PERSONAL_ACCESS_TOKEN=$($env:GITHUB_PERSONAL_ACCESS_TOKEN)",$IMG) + $Args
