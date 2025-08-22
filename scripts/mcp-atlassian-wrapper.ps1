<#!
.SYNOPSIS
  Atlassian (Local) MCP Server Wrapper (Windows PowerShell)
.DESCRIPTION
  Securely launches the Sooperset Atlassian MCP server using API token from Windows Credential Manager.
  
  Container runtime setup required:
    - Windows: Install Podman (preferred) or docker
    - (macOS users typically use Colima; this Windows script expects a docker-compatible CLI)

  Create Generic Credential for API token:
    Control Panel > User Accounts > Credential Manager > Windows Credentials > Add a generic credential
      Internet or network address: atlassian-mcp
      User name: api-token
      Password: <your Atlassian API token>

  Or via PowerShell:
  ```
   $secure = Read-Host -AsSecureString "Enter Atlassian API token"
   $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
   try {
     $plain = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
     # Use Start-Process so the literal token isn't echoed back; it's still passed in memory only.
     Start-Process -FilePath cmd.exe -ArgumentList "/c","cmdkey","/add:atlassian-mcp","/user:api-token","/pass:$plain" -WindowStyle Hidden -NoNewWindow -Wait
     [Console]::Error.WriteLine("Credential 'atlassian-mcp' created.")
   } finally {
     if ($bstr -ne [IntPtr]::Zero) { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr) }
   }
   ```

  API Token creation:
    1. Go to https://id.atlassian.com/manage-profile/security/api-tokens
    2. Create API token for your Atlassian account
    3. Store it securely in credential manager or environment variable

.PARAMETER Args
  Additional arguments passed through to the MCP server process.
#>
Param([Parameter(ValueFromRemainingArguments=$true)] [string[]]$Args)
# Startup order: local CLI on PATH -> npx (no global install, if package available) -> container (podman/docker)
# No automatic npm -g installs to avoid interactive prompts in editors (VS Code, Claude Desktop).
# Env overrides: MCP_ATLASSIAN_CLI_BIN, MCP_ATLASSIAN_NPM_PKG, MCP_ATLASSIAN_IMAGE/DOCKER_COMMAND
# Logging note: Diagnostics go to stderr intentionally to keep stdout JSON-only for MCP.
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Configuration defaults
if (-not $env:DOCKER_COMMAND) { $env:DOCKER_COMMAND = 'docker' }
if (-not $env:MCP_ATLASSIAN_IMAGE) { $env:MCP_ATLASSIAN_IMAGE = 'ghcr.io/sooperset/mcp-atlassian:latest' }
if (-not $env:AUTH_METHOD) { $env:AUTH_METHOD = 'api_token' }

function Test-DockerAvailable {
  try {
    $null = Get-Command $env:DOCKER_COMMAND -ErrorAction Stop
  } catch {
    Write-Error "$($env:DOCKER_COMMAND) is not installed or not in PATH. Install Podman (preferred) or docker for Windows."
    exit 1
  }
  
  # Check if container runtime daemon is running
  try {
    & $env:DOCKER_COMMAND info *>$null
  } catch {
    Write-Error "$($env:DOCKER_COMMAND) daemon is not running. Start Podman (podman machine start) or docker before using this wrapper."
    exit 1
  }
}

function Get-StoredPassword {
  param([string]$Target)

  # Check if credential exists
  $listing = cmd /c "cmdkey /list" 2>$null
  if (-not $listing -or $listing -notmatch $Target) {
    throw "Credential '$Target' not found in Windows Credential Manager."
  }

  $needAdminHint = $false
  $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

  # Need CredentialManager module to read the credential
  try {
    if (-not (Get-Module -ListAvailable -Name CredentialManager)) {
      Import-Module CredentialManager -ErrorAction Stop
    }
  } catch {
    $needAdminHint = -not $isAdmin
    throw ("Unable to import CredentialManager module. Install it first: Install-Module CredentialManager -Scope CurrentUser -Force" + `
      ($(if($needAdminHint){" (If you encounter policy/permission errors, reopen PowerShell as Administrator and retry the install)"})))
  }

  try {
    $cred = Get-StoredCredential -Target $Target
    if (-not $cred) {
      throw "Stored credential not accessible via CredentialManager module"
    }
    return $cred.Password
  } catch {
    throw "Unable to read credential for '$Target'. Ensure the module installed correctly and credential was created."
  }
}


# Check container runtime availability
Test-DockerAvailable

# Domain default if unset (can be overridden by env/config)
if (-not $env:ATLASSIAN_DOMAIN) {
  [Console]::Error.WriteLine("Note: ATLASSIAN_DOMAIN was not set; defaulting to 'guttmacher.atlassian.net'.")
  $env:ATLASSIAN_DOMAIN = 'guttmacher.atlassian.net'
}

# Get API token from environment or credential manager (for api_token auth method)
if ($env:AUTH_METHOD -eq 'api_token') {
  if ($env:ATLASSIAN_API_TOKEN) {
    $apiToken = $env:ATLASSIAN_API_TOKEN
  } else {
    try {
      $apiToken = Get-StoredPassword -Target 'atlassian-mcp'
    } catch {
      Write-Error @"
Could not retrieve Atlassian API token:
1. Create API token at: https://id.atlassian.com/manage-profile/security/api-tokens
2. Create credential 'atlassian-mcp' with user 'api-token' in Windows Credential Manager
"@
      exit 1
    }
  }
  
  # Set email if not provided (env -> git -> username@derived .org)
  if (-not $env:ATLASSIAN_EMAIL) {
    $gitEmail = $null
    if (Get-Command git -ErrorAction SilentlyContinue) {
      try {
        $gitEmail = (git config --get user.email 2>$null).Trim()
      } catch {}
    }
    if ($gitEmail) {
      $env:ATLASSIAN_EMAIL = $gitEmail
    } else {
      $derivedDomain = $env:ATLASSIAN_DOMAIN -replace '\.atlassian\.net$', '.org'
      $env:ATLASSIAN_EMAIL = "$env:USERNAME@$derivedDomain"
    }
    [Console]::Error.WriteLine("Note: Using derived email '$($env:ATLASSIAN_EMAIL)'. Set ATLASSIAN_EMAIL to override.")
  }
}

# Prefer npm-installed CLI if available (package may be private); otherwise use container
$CLI_BIN = $env:MCP_ATLASSIAN_CLI_BIN; if (-not $CLI_BIN) { $CLI_BIN = 'mcp-atlassian' }
$NPM_PKG = $env:MCP_ATLASSIAN_NPM_PKG; if (-not $NPM_PKG) { $NPM_PKG = '@sooperset/mcp-atlassian' }

function Invoke-Exec { param([string]$File,[string[]]$Arguments) & $File @Arguments; if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE } }

$prefEnv = @(
  "CONFLUENCE_URL=https://$($env:ATLASSIAN_DOMAIN)/wiki",
  "JIRA_URL=https://$($env:ATLASSIAN_DOMAIN)",
  "CONFLUENCE_USERNAME=$($env:ATLASSIAN_EMAIL)",
  "JIRA_USERNAME=$($env:ATLASSIAN_EMAIL)",
  "CONFLUENCE_API_TOKEN=$apiToken",
  "JIRA_API_TOKEN=$apiToken"
)

if (Get-Command $CLI_BIN -ErrorAction SilentlyContinue) {
  [Console]::Error.WriteLine("Using Atlassian MCP via local CLI on PATH: $CLI_BIN")
  $env:NO_COLOR = '1'
  foreach ($kv in $prefEnv) { $name,$val = $kv.Split('='); Set-Item -Path env:$name -Value $val }
  & $CLI_BIN @Args | ForEach-Object { if ($_ -match '^\s*$' -or $_ -match '^(?i)\s*Content-(Length|Type):' -or $_ -match '^\s*\{' -or $_ -match '^\s*\[\s*(\"|\{|\[|[0-9-]|t|f|n|\])') { $_ } else { [Console]::Error.WriteLine($_) } }
  if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

# Try npx as an optional fallback if available (no global install)
if ($NPM_PKG -and (Get-Command npx -ErrorAction SilentlyContinue)) {
  [Console]::Error.WriteLine("Using Atlassian MCP via npx package: $NPM_PKG@latest")
  $env:NO_COLOR = '1'
  $env:NPM_CONFIG_LOGLEVEL = 'silent'
  $env:NPM_CONFIG_FUND = 'false'
  $env:NPM_CONFIG_AUDIT = 'false'
  $env:NO_UPDATE_NOTIFIER = '1'
  $env:ADBLOCK = '1'
  foreach ($kv in $prefEnv) { $name,$val = $kv.Split('='); Set-Item -Path env:$name -Value $val }
  $npxArgs = @('-y', "$NPM_PKG@latest")
  & 'npx' @($npxArgs + $Args) | ForEach-Object { if ($_ -match '^\s*$' -or $_ -match '^(?i)\s*Content-(Length|Type):' -or $_ -match '^\s*\{' -or $_ -match '^\s*\[\s*(\"|\{|\[|[0-9-]|t|f|n|\])') { $_ } else { [Console]::Error.WriteLine($_) } }
  if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

# Fallback to container
# Ensure image present (auto-pull if missing)
try {
  & $env:DOCKER_COMMAND image inspect $env:MCP_ATLASSIAN_IMAGE 2>$null
  if ($LASTEXITCODE -ne 0) {
    [Console]::Error.WriteLine("Pulling Atlassian MCP Docker image: $($env:MCP_ATLASSIAN_IMAGE)")
    & $env:DOCKER_COMMAND pull $env:MCP_ATLASSIAN_IMAGE
    if ($LASTEXITCODE -ne 0) { Write-Error "Failed to pull image: $($env:MCP_ATLASSIAN_IMAGE)"; exit 1 }
  }
} catch {
  [Console]::Error.WriteLine("Pulling Atlassian MCP Docker image: $($env:MCP_ATLASSIAN_IMAGE)")
  & $env:DOCKER_COMMAND pull $env:MCP_ATLASSIAN_IMAGE
  if ($LASTEXITCODE -ne 0) { Write-Error "Failed to pull image: $($env:MCP_ATLASSIAN_IMAGE)"; exit 1 }
}
[Console]::Error.WriteLine("Using Atlassian MCP via container image: $($env:MCP_ATLASSIAN_IMAGE)")
$dockerEnvArgs = @(
  '-e','NO_COLOR=1',
  '-e', "CONFLUENCE_URL=https://$($env:ATLASSIAN_DOMAIN)/wiki",
  '-e', "JIRA_URL=https://$($env:ATLASSIAN_DOMAIN)",
  '-e', "CONFLUENCE_USERNAME=$($env:ATLASSIAN_EMAIL)",
  '-e', "CONFLUENCE_API_TOKEN=$apiToken",
  '-e', "JIRA_USERNAME=$($env:ATLASSIAN_EMAIL)",
  '-e', "JIRA_API_TOKEN=$apiToken"
)
$fullArgs = @('run', '--rm', '-i') + $dockerEnvArgs + @($env:MCP_ATLASSIAN_IMAGE) + $Args
& $env:DOCKER_COMMAND @fullArgs | ForEach-Object { if ($_ -match '^\s*$' -or $_ -match '^(?i)\s*Content-(Length|Type):' -or $_ -match '^\s*\{' -or $_ -match '^\s*\[\s*(\"|\{|\[|[0-9-]|t|f|n|\])') { $_ } else { [Console]::Error.WriteLine($_) } }
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
