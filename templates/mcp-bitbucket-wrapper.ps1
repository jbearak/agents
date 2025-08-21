<#!
.SYNOPSIS
  Bitbucket MCP Server Wrapper (Windows PowerShell)
.DESCRIPTION
  Securely launches the Bitbucket MCP server using app password from Windows Credential Manager.
  Username is provided via environment variable (set in JSON config).

  Create Generic Credential for app password only:
    Control Panel > User Accounts > Credential Manager > Windows Credentials > Add a generic credential
      Internet or network address: bitbucket-mcp
      User name: app-password
      Password: <your Bitbucket app password>

  Or via PowerShell:
    cmd /c "cmdkey /add:bitbucket-mcp /user:app-password /pass:<app_password>"

.PARAMETER Args
  Additional arguments passed through to the MCP server process.
#>
Param([Parameter(ValueFromRemainingArguments=$true)] [string[]]$Args)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Optional workspace override
if (-not $env:BITBUCKET_DEFAULT_WORKSPACE) { $env:BITBUCKET_DEFAULT_WORKSPACE = 'Guttmacher' }

function Get-StoredPassword {
  param([string]$Target)
  
  # Check if credential exists
  $listing = cmd /c "cmdkey /list" 2>$null
  if (-not $listing -or $listing -notmatch $Target) {
    throw "Credential '$Target' not found in Windows Credential Manager."
  }
  
  # Need CredentialManager module to read the credential
  try {
    if (-not (Get-Module -ListAvailable -Name CredentialManager)) { 
      Import-Module CredentialManager -ErrorAction Stop 
    }
    $cred = Get-StoredCredential -Target $Target
    if (-not $cred) { 
      throw "Stored credential not accessible via CredentialManager module" 
    }
    return $cred.Password
  } catch {
    throw "Unable to read credential for '$Target'. Install CredentialManager module: Install-Module CredentialManager -Scope CurrentUser"
  }
}

# Username is required from environment (set in JSON config)
if (-not $env:ATLASSIAN_BITBUCKET_USERNAME) {
  Write-Error "ATLASSIAN_BITBUCKET_USERNAME environment variable is required. This should be set in your agent configuration JSON file."
  exit 1
}

# Get app password from environment or credential manager
if ($env:ATLASSIAN_BITBUCKET_APP_PASSWORD) {
  $appPassword = $env:ATLASSIAN_BITBUCKET_APP_PASSWORD
} else {
  try {
    $appPassword = Get-StoredPassword -Target 'bitbucket-mcp'
  } catch {
    Write-Error "Could not retrieve Bitbucket app password. Either set environment variable ATLASSIAN_BITBUCKET_APP_PASSWORD or create credential 'bitbucket-mcp' with user 'app-password' in Windows Credential Manager."
    exit 1
  }
}

$env:ATLASSIAN_BITBUCKET_APP_PASSWORD = $appPassword

# Prefer npm-installed CLI; fallback to npx; optional container fallback
$CLI_BIN = $env:MCP_BITBUCKET_CLI_BIN; if (-not $CLI_BIN) { $CLI_BIN = 'mcp-atlassian-bitbucket' }
$NPM_PKG = $env:MCP_BITBUCKET_NPM_PKG; if (-not $NPM_PKG) { $NPM_PKG = '@aashari/mcp-server-atlassian-bitbucket' }
$IMG     = $env:MCP_BITBUCKET_DOCKER_IMAGE

function Invoke-Exec { param([string]$File,[string[]]$Arguments) & $File @Arguments; if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE } }

if (Get-Command $CLI_BIN -ErrorAction SilentlyContinue) {
  Invoke-Exec $CLI_BIN $Args
}

if (Get-Command npm -ErrorAction SilentlyContinue) {
  try { npm -g ls $NPM_PKG *>$null } catch {}
  if ($LASTEXITCODE -ne 0) { try { npm -g install $NPM_PKG *>$null } catch {} }
  if (Get-Command $CLI_BIN -ErrorAction SilentlyContinue) {
    Invoke-Exec $CLI_BIN $Args
  }
}

if (Get-Command npx -ErrorAction SilentlyContinue) {
  Invoke-Exec 'npx' @('-y', $NPM_PKG) + $Args
}

if ($IMG) {
  $runtime = if (Get-Command podman -ErrorAction SilentlyContinue) { 'podman' } elseif (Get-Command docker -ErrorAction SilentlyContinue) { 'docker' } else { $null }
  if (-not $runtime) { Write-Error 'Neither podman nor docker found on PATH.'; exit 1 }
  $envArgs = @('-e',"ATLASSIAN_BITBUCKET_USERNAME=$($env:ATLASSIAN_BITBUCKET_USERNAME)",'-e',"ATLASSIAN_BITBUCKET_APP_PASSWORD=$appPassword",'-e',"BITBUCKET_DEFAULT_WORKSPACE=$($env:BITBUCKET_DEFAULT_WORKSPACE)")
  Invoke-Exec $runtime @('run','-i','--rm','--pull=never') + $envArgs + @($IMG) + $Args
}

Write-Error 'Bitbucket MCP CLI not found and no viable fallback (npm/npx/docker) available.'
exit 1
