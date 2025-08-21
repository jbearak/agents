#!/usr/bin/env bash
# Bitbucket MCP Server Wrapper (macOS / Linux)
# Securely launches the Bitbucket MCP server with app password from macOS Keychain (macOS) or environment variables (fallback)
#
# Keychain setup (macOS):
#   security add-generic-password -s "bitbucket-mcp" -a "app-password" -w "<app_password>"
#   (Or use Keychain Access GUI: New Password Item... Name: bitbucket-mcp, Account: app-password, Password: <app_password>)
# Usage:
#   1. Create keychain entry (see above) OR export ATLASSIAN_BITBUCKET_APP_PASSWORD before running.
#   2. Username is provided via ATLASSIAN_BITBUCKET_USERNAME environment variable (set in JSON config).
#   3. Run: ./mcp-bitbucket-wrapper.sh [args]
#
# Environment variables required:
#   ATLASSIAN_BITBUCKET_USERNAME (required: Bitbucket username)
# Environment variables optional:
#   BITBUCKET_DEFAULT_WORKSPACE (default: Guttmacher)
#   ATLASSIAN_BITBUCKET_APP_PASSWORD (overrides keychain)
#
set -euo pipefail

SERVICE_NAME="bitbucket-mcp"
ACCOUNT_NAME="app-password"

get_keychain_password() {
  if [[ "$(uname)" != "Darwin" ]]; then
    return 1
  fi
  
  security find-generic-password -s "$SERVICE_NAME" -a "$ACCOUNT_NAME" -w 2>/dev/null || return 1
}

# Username is required from environment (set in JSON config)
if [[ -z "${ATLASSIAN_BITBUCKET_USERNAME:-}" ]]; then
  echo "Error: ATLASSIAN_BITBUCKET_USERNAME environment variable is required." >&2
  echo "This should be set in your agent configuration JSON file." >&2
  exit 1
fi

# Get app password from environment or keychain
if [[ -n "${ATLASSIAN_BITBUCKET_APP_PASSWORD:-}" ]]; then
  APP_PASS="$ATLASSIAN_BITBUCKET_APP_PASSWORD"
else
  if [[ "$(uname)" == "Darwin" ]]; then
    if ! APP_PASS=$(get_keychain_password); then
      echo "Error: Could not retrieve Bitbucket app password from Keychain (service '$SERVICE_NAME', account '$ACCOUNT_NAME')." >&2
      echo "Add it with: security add-generic-password -s '$SERVICE_NAME' -a '$ACCOUNT_NAME' -w '<app_password>'" >&2
      echo "Or set environment variable: export ATLASSIAN_BITBUCKET_APP_PASSWORD='<app_password>'" >&2
      exit 1
    fi
  else
    echo "Error: ATLASSIAN_BITBUCKET_APP_PASSWORD is not set and macOS Keychain is unavailable on this platform." >&2
    exit 1
  fi
fi

export ATLASSIAN_BITBUCKET_USERNAME="$ATLASSIAN_BITBUCKET_USERNAME"
export ATLASSIAN_BITBUCKET_APP_PASSWORD="$APP_PASS"
export BITBUCKET_DEFAULT_WORKSPACE="${BITBUCKET_DEFAULT_WORKSPACE:-Guttmacher}"

exec npx -y @aashari/mcp-server-atlassian-bitbucket "$@"
