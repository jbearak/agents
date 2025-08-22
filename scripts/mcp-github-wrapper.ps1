Param([Parameter(ValueFromRemainingArguments=$true)] [string[]]$Args)
# GitHub MCP Server wrapper - Docker/Podman version
# Uses the official GitHub MCP server Docker image
# Env overrides: MCP_GITHUB_DOCKER_IMAGE
# Logging note: Diagnostics go to stderr intentionally to keep stdout JSON-only for MCP.
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Obtain GitHub token (prefer env var, fallback to Windows Credential Manager)
if (-not $env:GITHUB_PERSONAL_ACCESS_TOKEN) {
  try { Import-Module CredentialManager -ErrorAction Stop } catch { Write-Error 'Install CredentialManager: Install-Module CredentialManager -Scope CurrentUser'; exit 1 }
  # Try both common targets: 'github-mcp' (wrapper default) and 'GitHub' (docs/older installs)
  $cred = Get-StoredCredential -Target 'github-mcp'
  if (-not $cred) { $cred = Get-StoredCredential -Target 'GitHub' }
  if (-not $cred) { Write-Error "Credential 'github-mcp' or 'GitHub' not found and GITHUB_PERSONAL_ACCESS_TOKEN not set"; exit 1 }
  $env:GITHUB_PERSONAL_ACCESS_TOKEN = $cred.Password
}

# Ensure stdio transport unless explicitly provided
if (-not ($Args -contains 'stdio' -or $Args -contains '--stdio' -or $Args -contains '--sse' -or ($Args | Where-Object { $_ -like '--transport=*' -or $_ -like '--http*' -or $_ -like '--sse*' -or $_ -eq '--port' -or $_ -eq '--host' }))) {
  $Args = @('stdio') + $Args
}

# Defaults
$IMG = $env:MCP_GITHUB_DOCKER_IMAGE; if (-not $IMG) { $IMG = 'ghcr.io/github/github-mcp-server:latest' }
$REMOTE_URL = $env:GITHUB_MCP_REMOTE_URL; if (-not $REMOTE_URL) { $REMOTE_URL = 'https://api.githubcopilot.com/mcp/' }

function Invoke-Exec { param([string]$File,[string[]]$Arguments) & $File @Arguments; if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE } }

function Use-RemoteServer {
  [Console]::Error.WriteLine("Falling back to remote GitHub MCP server: $REMOTE_URL")
  
  try {
    $headers = @{
      'Authorization' = "Bearer $($env:GITHUB_PERSONAL_ACCESS_TOKEN)"
      'Content-Type' = 'application/json'
      'Accept' = 'application/json'
    }
    
    # Read and process MCP messages line by line
    do {
      $inputLine = [System.Console]::In.ReadLine()
      if ($inputLine -and $inputLine.Trim() -ne '') {
        try {
          $response = Invoke-WebRequest -Uri $REMOTE_URL -Method POST -Headers $headers -Body $inputLine -UseBasicParsing -ErrorAction Stop
          [System.Console]::WriteLine($response.Content)
        } catch {
          [Console]::Error.WriteLine("Error communicating with remote server: $_")
          break
        }
      }
    } while ($inputLine -ne $null)
    
  } catch {
    [Console]::Error.WriteLine("Error: Failed to connect to remote GitHub MCP server.")
    [Console]::Error.WriteLine("Please check your GITHUB_PERSONAL_ACCESS_TOKEN and network connection.")
    exit 1
  }
}

# Find container runtime (prefer Podman on Windows)
$runtime = if (Get-Command podman -ErrorAction SilentlyContinue) { 'podman' } elseif (Get-Command docker -ErrorAction SilentlyContinue) { 'docker' } else { $null }

if (-not $runtime) {
  Write-Error 'Error: No container runtime found. Please install Docker or Podman.'
  [Console]::Error.WriteLine('Attempting to use remote server fallback...')
  Use-RemoteServer
}

# Check if container runtime daemon is running
try {
  & $runtime info 2>&1 | Out-Null
  if ($LASTEXITCODE -ne 0) {
    Write-Error "Error: $runtime daemon is not running. Please start it first."
    [Console]::Error.WriteLine('Attempting to use remote server fallback...')
    Use-RemoteServer
  }
} catch {
  Write-Error "Error: Failed to check $runtime daemon status."
  [Console]::Error.WriteLine('Attempting to use remote server fallback...')
  Use-RemoteServer
}

# Ensure image present (auto-pull if missing)
try {
  & $runtime image inspect $IMG 2>&1 | Out-Null
  if ($LASTEXITCODE -ne 0) {
    [Console]::Error.WriteLine("Pulling GitHub MCP Docker image: $IMG")
& $runtime pull $IMG
    if ($LASTEXITCODE -ne 0) { 
      Write-Error "Failed to pull image: $IMG"
      [Console]::Error.WriteLine('Attempting to use remote server fallback...')
      Use-RemoteServer
    }
    [Console]::Error.WriteLine("Pulled GitHub MCP Docker image successfully: $IMG")
  }
} catch {
  [Console]::Error.WriteLine("Pulling GitHub MCP Docker image: $IMG")
  & $runtime pull $IMG
  if ($LASTEXITCODE -ne 0) { 
    Write-Error "Failed to pull image: $IMG"
    [Console]::Error.WriteLine('Attempting to use remote server fallback...')
    Use-RemoteServer
  }
  [Console]::Error.WriteLine("Pulled GitHub MCP Docker image successfully: $IMG")
}

[Console]::Error.WriteLine("Using GitHub MCP via container image: $IMG")

# Run the container
Invoke-Exec $runtime @('run','-i','--rm','-e',"GITHUB_PERSONAL_ACCESS_TOKEN=$($env:GITHUB_PERSONAL_ACCESS_TOKEN)",$IMG) + $Args
