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
      Internet or network address: atlassian-mcp-local
      User name: api-token
      Password: <your Atlassian API token>

  Or via PowerShell:
  ```
   $secure = Read-Host -AsSecureString "Enter Atlassian API token"
   $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
   try {
     $plain = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
     # Use Start-Process so the literal token isn't echoed back; it's still passed in memory only.
     Start-Process -FilePath cmd.exe -ArgumentList "/c","cmdkey","/add:atlassian-mcp-local","/user:api-token","/pass:$plain" -WindowStyle Hidden -NoNewWindow -Wait
     Write-Host "Credential 'atlassian-mcp-local' created." -ForegroundColor Green
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

function Update-AtlassianImage {
  Write-Host "Checking for latest Atlassian MCP server image..." -ForegroundColor Yellow
  try {
    & $env:DOCKER_COMMAND pull $env:MCP_ATLASSIAN_IMAGE 2>$null
  } catch {
    Write-Warning "Failed to pull latest image. Using local version if available."
  }
}

# Check container runtime availability
Test-DockerAvailable

# Domain is required from environment (set in JSON config)
if (-not $env:ATLASSIAN_DOMAIN) {
  Write-Error "ATLASSIAN_DOMAIN environment variable is required. This should be set in your agent configuration JSON file (e.g., 'guttmacher.atlassian.net')."
  exit 1
}

# Get API token from environment or credential manager (for api_token auth method)
if ($env:AUTH_METHOD -eq 'api_token') {
  if ($env:ATLASSIAN_API_TOKEN) {
    $apiToken = $env:ATLASSIAN_API_TOKEN
  } else {
    try {
      $apiToken = Get-StoredPassword -Target 'atlassian-mcp-local'
    } catch {
      Write-Error @"
Could not retrieve Atlassian API token:
1. Create API token at: https://id.atlassian.com/manage-profile/security/api-tokens
2. Create credential 'atlassian-mcp-local' with user 'api-token' in Windows Credential Manager
"@
      exit 1
    }
  }
  
  # Set email if not provided (required for API token auth)
  if (-not $env:ATLASSIAN_EMAIL) {
    # Try to derive from current user or domain
    $derivedDomain = $env:ATLASSIAN_DOMAIN -replace '\.atlassian\.net$', '.com'
    $env:ATLASSIAN_EMAIL = "$env:USERNAME@$derivedDomain"
    Write-Host "Note: Using derived email '$($env:ATLASSIAN_EMAIL)'. Set ATLASSIAN_EMAIL to override." -ForegroundColor Yellow
  }
}

# Pull latest image
Update-AtlassianImage

# Set up environment variables for the container
$dockerEnvArgs = @(
  '-e', "CONFLUENCE_URL=https://$($env:ATLASSIAN_DOMAIN)/wiki"
  '-e', "JIRA_URL=https://$($env:ATLASSIAN_DOMAIN)"
)

if ($env:AUTH_METHOD -eq 'api_token') {
  $dockerEnvArgs += @(
    '-e', "CONFLUENCE_USERNAME=$($env:ATLASSIAN_EMAIL)"
    '-e', "CONFLUENCE_API_TOKEN=$apiToken"
    '-e', "JIRA_USERNAME=$($env:ATLASSIAN_EMAIL)"
    '-e', "JIRA_API_TOKEN=$apiToken"
  )
} elseif ($env:AUTH_METHOD -eq 'oauth') {
  # OAuth setup - user must provide these externally
  if ($env:ATLASSIAN_OAUTH_CLIENT_ID) {
    $dockerEnvArgs += @('-e', "ATLASSIAN_OAUTH_CLIENT_ID=$($env:ATLASSIAN_OAUTH_CLIENT_ID)")
  }
  if ($env:ATLASSIAN_OAUTH_CLIENT_SECRET) {
    $dockerEnvArgs += @('-e', "ATLASSIAN_OAUTH_CLIENT_SECRET=$($env:ATLASSIAN_OAUTH_CLIENT_SECRET)")
  }
  if ($env:ATLASSIAN_OAUTH_REDIRECT_URI) {
    $dockerEnvArgs += @('-e', "ATLASSIAN_OAUTH_REDIRECT_URI=$($env:ATLASSIAN_OAUTH_REDIRECT_URI)")
  }
  if ($env:ATLASSIAN_OAUTH_SCOPE) {
    $dockerEnvArgs += @('-e', "ATLASSIAN_OAUTH_SCOPE=$($env:ATLASSIAN_OAUTH_SCOPE)")
  }
  if ($env:ATLASSIAN_OAUTH_CLOUD_ID) {
    $dockerEnvArgs += @('-e', "ATLASSIAN_OAUTH_CLOUD_ID=$($env:ATLASSIAN_OAUTH_CLOUD_ID)")
  }
}

# Launch the container in interactive mode with stdin/stdout
$fullArgs = @('run', '--rm', '-i') + $dockerEnvArgs + @($env:MCP_ATLASSIAN_IMAGE) + $Args

& $env:DOCKER_COMMAND @fullArgs
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
