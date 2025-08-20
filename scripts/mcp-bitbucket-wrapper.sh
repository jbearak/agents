#!/usr/bin/env bash
# Bitbucket MCP Server Wrapper (macOS / Linux)
# Securely launches the Bitbucket MCP server with credentials from macOS Keychain (macOS) or environment variables (fallback)
#
# Recommended: store ONLY the app password in Keychain; username is not secret.
# Keychain setup (macOS):
#   security add-generic-password -s "bitbucket-mcp" -a "app-password" -w "<app_password>"
#   (Or use Keychain Access GUI: New Password Item... Name: bitbucket-mcp, Account: app-password, Password: <app_password>)
# Usage:
#   1. Edit ATLASSIAN_BITBUCKET_USERNAME below to your Bitbucket username (NOT your email address!)
#   2. Ensure keychain item exists (see above) OR export ATLASSIAN_BITBUCKET_APP_PASSWORD before running.
#   3. Run: ./mcp-bitbucket-wrapper.sh [args]
#
# Environment overrides (optional):
#   BITBUCKET_DEFAULT_WORKSPACE (default: Guttmacher)
#
set -euo pipefail

SERVICE_NAME="bitbucket-mcp"
ACCOUNT_NAME="app-password"

get_keychain_password() {
  security find-generic-password -s "$SERVICE_NAME" -a "$ACCOUNT_NAME" -w 2>/dev/null || return 1
}

ATLASSIAN_BITBUCKET_USERNAME="<username>"  # <-- CHANGE THIS
if [[ "$ATLASSIAN_BITBUCKET_USERNAME" == "<username>" ]]; then
  echo "Error: Please edit ATLASSIAN_BITBUCKET_USERNAME in $(basename "$0") before use." >&2
  exit 1
fi

if [[ -n "${ATLASSIAN_BITBUCKET_APP_PASSWORD:-}" ]]; then
  APP_PASS="$ATLASSIAN_BITBUCKET_APP_PASSWORD"
else
  if APP_PASS=$(get_keychain_password); then
    :
  else
    echo "Error: Could not retrieve Bitbucket app password from Keychain (service '$SERVICE_NAME', account '$ACCOUNT_NAME')." >&2
    echo "Add it with: security add-generic-password -s '$SERVICE_NAME' -a '$ACCOUNT_NAME' -w '<app_password>'" >&2
    exit 1
  fi
fi

export ATLASSIAN_BITBUCKET_USERNAME
export ATLASSIAN_BITBUCKET_APP_PASSWORD="$APP_PASS"
export BITBUCKET_DEFAULT_WORKSPACE="${BITBUCKET_DEFAULT_WORKSPACE:-Guttmacher}"

exec npx -y @aashari/mcp-server-atlassian-bitbucket "$@"
