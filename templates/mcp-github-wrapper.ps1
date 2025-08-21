Param([Parameter(ValueFromRemainingArguments=$true)] [string[]]$Args)
# Startup order preference (Windows): local CLI -> npx (@latest, no global install) -> container
# No automatic npm -g installs to avoid interactive prompts in editors (VS Code, Claude Desktop).
# Env overrides: MCP_GITHUB_CLI_BIN, MCP_GITHUB_NPM_PKG, MCP_GITHUB_DOCKER_IMAGE
# Logging note: Diagnostics go to stderr intentionally to keep stdout JSON-only for MCP.
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Obtain GitHub token (prefer env var, fallback to Windows Credential Manager)
if (-not $env:GITHUB_PERSONAL_ACCESS_TOKEN) {
  try { Import-Module CredentialManager -ErrorAction Stop } catch { Write-Error 'Install CredentialManager: Install-Module CredentialManager -Scope CurrentUser'; exit 1 }
  $cred = Get-StoredCredential -Target 'github-mcp'
  if (-not $cred) { Write-Error "Credential 'github-mcp' not found and GITHUB_PERSONAL_ACCESS_TOKEN not set"; exit 1 }
  $env:GITHUB_PERSONAL_ACCESS_TOKEN = $cred.Password
}

# Defaults
$CLI_BIN = $env:MCP_GITHUB_CLI_BIN; if (-not $CLI_BIN) { $CLI_BIN = 'github-mcp-server' }
$NPM_PKG = $env:MCP_GITHUB_NPM_PKG; if (-not $NPM_PKG) { $NPM_PKG = 'github-mcp-server' }
$IMG     = $env:MCP_GITHUB_DOCKER_IMAGE; if (-not $IMG) { $IMG = 'ghcr.io/github/github-mcp-server:latest' }

function Invoke-Exec { param([string]$File,[string[]]$Arguments) & $File @Arguments; if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE } }

# 1) Prefer local CLI for fastest startup
if (Get-Command $CLI_BIN -ErrorAction SilentlyContinue) {
  [Console]::Error.WriteLine("Using GitHub MCP via local CLI on PATH: $CLI_BIN")
  $env:NO_COLOR = '1'
  Invoke-Exec $CLI_BIN $Args
}

# 2) Try npx @latest (no global install)
if (Get-Command npx -ErrorAction SilentlyContinue) {
  [Console]::Error.WriteLine("Using GitHub MCP via npx package: $NPM_PKG@latest")
  $env:NO_COLOR = '1'
  $env:NPM_CONFIG_LOGLEVEL = 'silent'
  $env:NPM_CONFIG_FUND = 'false'
  $env:NPM_CONFIG_AUDIT = 'false'
  $env:NO_UPDATE_NOTIFIER = '1'
  $env:ADBLOCK = '1'
  $npxArgs = @('-y', "$NPM_PKG@latest")
  Invoke-Exec 'npx' $npxArgs + $Args
}

# 3) Fallback: container (reliable, stdout-clean)
$runtime = if (Get-Command podman -ErrorAction SilentlyContinue) { 'podman' } elseif (Get-Command docker -ErrorAction SilentlyContinue) { 'docker' } else { $null }
if ($runtime) {
  [Console]::Error.WriteLine("Using GitHub MCP via container image: $IMG")
  Invoke-Exec $runtime @('run','-i','--rm','--pull=never','-e','NO_COLOR=1','-e',"GITHUB_PERSONAL_ACCESS_TOKEN=$($env:GITHUB_PERSONAL_ACCESS_TOKEN)",$IMG) + $Args
}

Write-Error 'Error: Could not start GitHub MCP server via local CLI, npx, or container.'
exit 1
