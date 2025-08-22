<#!
.SYNOPSIS
  Context7 MCP Server Wrapper (Windows PowerShell)
.DESCRIPTION
  Launches the Context7 MCP server using installed npm package or fallback to npx.
  
  Prerequisites:
    - Node.js and npm installed
    - Optional: Install globally with 'npm install -g @upstash/context7-mcp@latest'
  
  Startup order: installed npm package -> npx

.PARAMETER Args
  Additional arguments passed through to the MCP server process.
#>
Param([Parameter(ValueFromRemainingArguments=$true)] [string[]]$Args)
# Startup order: installed npm package -> npx
# Env overrides: NPM_PKG_CONTEXT7/NODE_ENV
# Logging note: Diagnostics go to stderr intentionally to keep stdout JSON-only for MCP.
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Configuration defaults
if (-not $env:NPM_PKG_CONTEXT7) { $env:NPM_PKG_CONTEXT7 = '@upstash/context7-mcp' }
if (-not $env:NODE_ENV) { $env:NODE_ENV = 'production' }

# Keep stdout clean when npm/npx is used
$env:NO_COLOR = '1'
$env:NPM_CONFIG_LOGLEVEL = 'silent'
$env:npm_config_loglevel = 'silent'
$env:NPM_CONFIG_FUND = 'false'
$env:NPM_CONFIG_AUDIT = 'false'
$env:NO_UPDATE_NOTIFIER = '1'
$env:ADBLOCK = '1'

function Test-NodeAvailable {
  try {
    $null = Get-Command node -ErrorAction Stop
  } catch {
    Write-Error "Node.js is not installed or not in PATH. Please install Node.js to use the Context7 MCP server."
    exit 1
  }
}

function Test-NpmAvailable {
  try {
    $null = Get-Command npm -ErrorAction Stop
  } catch {
    Write-Error "npm is not installed or not in PATH. Please install npm to use the Context7 MCP server."
    exit 1
  }
}

function Test-PackageInstalled {
  try {
    & npm list -g $env:NPM_PKG_CONTEXT7 *>$null
    return $LASTEXITCODE -eq 0
  } catch {
    return $false
  }
}

function Invoke-InstalledPackage {
  try {
    $packagePath = (& npm list -g $env:NPM_PKG_CONTEXT7 --parseable 2>$null | Select-Object -First 1).Trim()
    if ($packagePath -and (Test-Path $packagePath)) {
      $mainScript = Join-Path $packagePath "dist\index.js"
      if (Test-Path $mainScript) {
        [Console]::Error.WriteLine("Using installed Context7 MCP package: $($env:NPM_PKG_CONTEXT7)")
        & node $mainScript @Args | ForEach-Object { 
          if ($_ -match '^\s*$' -or $_ -match '^(?i)\s*Content-(Length|Type):' -or $_ -match '^\s*\{' -or $_ -match '^\s*\[\s*(\"|\{|\[|[0-9-]|t|f|n|\])') { 
            $_ 
          } else { 
            [Console]::Error.WriteLine($_) 
          } 
        }
        return $LASTEXITCODE -eq 0
      }
    }
    return $false
  } catch {
    return $false
  }
}

function Invoke-Npx {
  try {
    $null = Get-Command npx -ErrorAction Stop
  } catch {
    [Console]::Error.WriteLine("Error: npx is not available.")
    return $false
  }
  
  [Console]::Error.WriteLine("Using Context7 MCP via npx: $($env:NPM_PKG_CONTEXT7)@latest")
  & npx -y "$($env:NPM_PKG_CONTEXT7)@latest" @Args | ForEach-Object { 
    if ($_ -match '^\s*$' -or $_ -match '^(?i)\s*Content-(Length|Type):' -or $_ -match '^\s*\{' -or $_ -match '^\s*\[\s*(\"|\{|\[|[0-9-]|t|f|n|\])') { 
      $_ 
    } else { 
      [Console]::Error.WriteLine($_) 
    } 
  }
  return $LASTEXITCODE -eq 0
}

# Main execution logic
Test-NodeAvailable
Test-NpmAvailable

# Try installed package first, then fallback to npx
if ((Test-PackageInstalled) -and (Invoke-InstalledPackage)) {
  exit 0
} else {
  [Console]::Error.WriteLine("Note: $($env:NPM_PKG_CONTEXT7) not found globally installed, falling back to npx...")
  if (Invoke-Npx) {
    exit 0
  } else {
    Write-Error "Failed to run Context7 MCP server via both installed package and npx. Try installing globally with: npm install -g $($env:NPM_PKG_CONTEXT7)@latest"
    exit 1
  }
}
