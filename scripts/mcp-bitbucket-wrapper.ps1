<#!
.SYNOPSIS
  Bitbucket MCP Server Wrapper (Windows PowerShell)
.DESCRIPTION
  Securely launches the Bitbucket MCP server using a Generic Credential stored in Windows Credential Manager.
  Only LOCAL MCP server usage is supported; Bitbucket does not have an official remote MCP server.

  Create Generic Credential:
    Control Panel > User Accounts > Credential Manager > Windows Credentials > Add a generic credential
      Internet or network address: bitbucket-mcp
      User name: app-password
      Password: <your Bitbucket app password>

  Or via PowerShell (run as current user):
    cmd /c "cmdkey /add:bitbucket-mcp /user:app-password /pass:<your Bitbucket app password>"

  NOTE: Set the Bitbucket username below (NOT an email address). Find it at:
    https://bitbucket.org/account/settings/  ("Username" field in profile settings)

.PARAMETER Args
  Additional arguments passed through to the MCP server process.
#>
Param([Parameter(ValueFromRemainingArguments=$true)] [string[]]$Args)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Bitbucket username (NOT email) - CHANGE THIS
$env:ATLASSIAN_BITBUCKET_USERNAME = '<username>'
if ($env:ATLASSIAN_BITBUCKET_USERNAME -eq '<username>') {
  Write-Error "Please edit ATLASSIAN_BITBUCKET_USERNAME in $(Split-Path -Leaf $PSCommandPath) before use."; exit 1
}

# Optional workspace override
if (-not $env:BITBUCKET_DEFAULT_WORKSPACE) { $env:BITBUCKET_DEFAULT_WORKSPACE = 'Guttmacher' }

function Get-AppPassword {
  $target = 'bitbucket-mcp'
  # Use cmdkey to enumerate, then parse. (CredentialManager module not strictly required.)
  $listing = cmd /c "cmdkey /list" 2>$null
  if (-not $listing -or $listing -notmatch $target) {
    Write-Error "Credential '$target' not found. Create it in Windows Credential Manager (Generic Credentials)."; exit 1
  }
  # Need password retrieval; cmdkey cannot output password. Use CredentialManager module if available.
  try {
    if (-not (Get-Module -ListAvailable -Name CredentialManager)) { Import-Module CredentialManager -ErrorAction Stop }
    $cred = Get-StoredCredential -Target $target
    if (-not $cred) { throw "Stored credential not accessible via CredentialManager module" }
    return $cred.Password
  } catch {
    Write-Error "Unable to read password for '$target'. Install CredentialManager module: Install-Module CredentialManager -Scope CurrentUser"; exit 1
  }
}

if (-not $env:ATLASSIAN_BITBUCKET_APP_PASSWORD -or [string]::IsNullOrWhiteSpace($env:ATLASSIAN_BITBUCKET_APP_PASSWORD)) {
  $env:ATLASSIAN_BITBUCKET_APP_PASSWORD = Get-AppPassword
}

# Launch via npx (ensures latest published version unless cached)
# Consider pinning a version in highly controlled environments.
$command = 'npx'
$fullArgs = @('-y', '@aashari/mcp-server-atlassian-bitbucket') + $Args

# Exec equivalent in PowerShell
& $command @fullArgs
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
