<#!
.SYNOPSIS
  Bitbucket MCP Server Wrapper (Windows PowerShell)
.DESCRIPTION
  Securely launches the Bitbucket MCP server using a Generic Credential stored in Windows Credential Manager.
  Only LOCAL MCP server usage is supported; Bitbucket does not have an official remote MCP server.

  Create Generic Credential:
    Control Panel > User Accounts > Credential Manager > Windows Credentials > Add a generic credential
      Internet or network address: bitbucket-mcp
      User name: <your Bitbucket username>
      Password: <your Bitbucket app password>

  Or via PowerShell (run as current user):
    cmd /c "cmdkey /add:bitbucket-mcp /user:<username> /pass:<app_password>"

  NOTE: Use your Bitbucket username (NOT email address) from:
    https://bitbucket.org/account/settings/  ("Username" field in profile settings)

.PARAMETER Args
  Additional arguments passed through to the MCP server process.
#>
Param([Parameter(ValueFromRemainingArguments=$true)] [string[]]$Args)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Optional workspace override
if (-not $env:BITBUCKET_DEFAULT_WORKSPACE) { $env:BITBUCKET_DEFAULT_WORKSPACE = 'Guttmacher' }

function Get-StoredCredential {
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
    return @{
      Username = $cred.UserName
      Password = $cred.Password
    }
  } catch {
    throw "Unable to read credential for '$Target'. Install CredentialManager module: Install-Module CredentialManager -Scope CurrentUser"
  }
}

# Get credentials from environment or credential manager
if ($env:ATLASSIAN_BITBUCKET_USERNAME -and $env:ATLASSIAN_BITBUCKET_APP_PASSWORD) {
  $username = $env:ATLASSIAN_BITBUCKET_USERNAME
  $appPassword = $env:ATLASSIAN_BITBUCKET_APP_PASSWORD
} else {
  try {
    $credential = Get-StoredCredential -Target 'bitbucket-mcp'
    $username = $credential.Username
    $appPassword = $credential.Password
  } catch {
    Write-Error "Could not retrieve Bitbucket credentials. Either set environment variables ATLASSIAN_BITBUCKET_USERNAME and ATLASSIAN_BITBUCKET_APP_PASSWORD or create credential 'bitbucket-mcp' in Windows Credential Manager."
    exit 1
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
