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

# Launch via npx (ensures latest published version unless cached)
$command = 'npx'
$fullArgs = @('-y', '@aashari/mcp-server-atlassian-bitbucket') + $Args

# Exec equivalent in PowerShell
& $command @fullArgs
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
