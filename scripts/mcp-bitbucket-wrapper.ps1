<#!
.SYNOPSIS
  Bitbucket MCP Server Wrapper (Windows PowerShell)
.DESCRIPTION
  Securely launches the Bitbucket MCP server using Generic Credentials stored in Windows Credential Manager.
  Only LOCAL MCP server usage is supported; Bitbucket does not have an official remote MCP server.

  Create Generic Credentials (no script editing needed):
    Control Panel > User Accounts > Credential Manager > Windows Credentials > Add a generic credential
      First credential:
        Internet or network address: bitbucket-mcp-username
        User name: username
        Password: <your Bitbucket username>
      Second credential:
        Internet or network address: bitbucket-mcp
        User name: app-password
        Password: <your Bitbucket app password>

  Or via PowerShell (run as current user):
    cmd /c "cmdkey /add:bitbucket-mcp-username /user:username /pass:<your Bitbucket username>"
    cmd /c "cmdkey /add:bitbucket-mcp /user:app-password /pass:<your Bitbucket app password>"

  NOTE: Find your Bitbucket username (NOT email address) at:
    https://bitbucket.org/account/settings/  ("Username" field in profile settings)

.PARAMETER Args
  Additional arguments passed through to the MCP server process.
#>
Param([Parameter(ValueFromRemainingArguments=$true)] [string[]]$Args)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Optional workspace override
if (-not $env:BITBUCKET_DEFAULT_WORKSPACE) { $env:BITBUCKET_DEFAULT_WORKSPACE = 'Guttmacher' }

function Get-StoredValue {
  param([string]$Target, [string]$Account)
  
  # Use cmdkey to enumerate, then parse. (CredentialManager module not strictly required.)
  $listing = cmd /c "cmdkey /list" 2>$null
  if (-not $listing -or $listing -notmatch $Target) {
    Write-Error "Credential '$Target' not found. Create it in Windows Credential Manager (Generic Credentials)."; exit 1
  }
  # Need password retrieval; cmdkey cannot output password. Use CredentialManager module if available.
  try {
    if (-not (Get-Module -ListAvailable -Name CredentialManager)) { Import-Module CredentialManager -ErrorAction Stop }
    $cred = Get-StoredCredential -Target $Target
    if (-not $cred) { throw "Stored credential not accessible via CredentialManager module" }
    return $cred.Password
  } catch {
    Write-Error "Unable to read password for '$Target'. Install CredentialManager module: Install-Module CredentialManager -Scope CurrentUser"; exit 1
  }
}

# Get username from environment or credential manager
if ($env:ATLASSIAN_BITBUCKET_USERNAME) {
  $username = $env:ATLASSIAN_BITBUCKET_USERNAME
} else {
  try {
    $username = Get-StoredValue -Target 'bitbucket-mcp-username' -Account 'username'
  } catch {
    Write-Error "Could not retrieve Bitbucket username. Either set environment variable ATLASSIAN_BITBUCKET_USERNAME or create credential 'bitbucket-mcp-username'."; exit 1
  }
}

# Get app password from environment or credential manager  
if ($env:ATLASSIAN_BITBUCKET_APP_PASSWORD) {
  $appPassword = $env:ATLASSIAN_BITBUCKET_APP_PASSWORD
} else {
  try {
    $appPassword = Get-StoredValue -Target 'bitbucket-mcp' -Account 'app-password'
  } catch {
    Write-Error "Could not retrieve Bitbucket app password. Either set environment variable ATLASSIAN_BITBUCKET_APP_PASSWORD or create credential 'bitbucket-mcp'."; exit 1
  }
}

$env:ATLASSIAN_BITBUCKET_USERNAME = $username
$env:ATLASSIAN_BITBUCKET_APP_PASSWORD = $appPassword

# Launch via npx (ensures latest published version unless cached)
# Consider pinning a version in highly controlled environments.
$command = 'npx'
$fullArgs = @('-y', '@aashari/mcp-server-atlassian-bitbucket') + $Args

# Exec equivalent in PowerShell
& $command @fullArgs
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
