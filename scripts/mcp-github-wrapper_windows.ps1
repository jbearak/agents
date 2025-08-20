Param([Parameter(ValueFromRemainingArguments=$true)] [string[]]$Args)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
try {
  Import-Module CredentialManager -ErrorAction Stop
} catch {
  Write-Error 'Install CredentialManager module first'; exit 1
}
$cred = Get-StoredCredential -Target 'GitHub'
if (-not $cred) { Write-Error "Credential 'GitHub' not found"; exit 1 }
$env:GITHUB_PERSONAL_ACCESS_TOKEN = $cred.Password
podman run -i --rm `
  -e GITHUB_PERSONAL_ACCESS_TOKEN=$env:GITHUB_PERSONAL_ACCESS_TOKEN `
  ghcr.io/github/github-mcp-server @Args
