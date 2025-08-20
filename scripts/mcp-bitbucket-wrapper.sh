#!/usr/bin/env bash
# Bitbucket MCP Server Wrapper (macOS / Linux)
# Securely launches the Bitbucket MCP server with credentials from macOS Keychain (macOS) or environment variables (fallback)
#
# Recommended: store both username and app password in Keychain; no script editing needed.
# Keychain setup (macOS):
#   security add-generic-password -s "bitbucket-mcp" -a "username" -w "<username>"
#   security add-generic-password -s "bitbucket-mcp" -a "app-password" -w "<app_password>"
#   (Or use Keychain Access GUI: New Password Item... Name: bitbucket-mcp, Account: username/app-password, Password: <value>)
# Usage:
#   1. Ensure keychain items exist (see above) OR export ATLASSIAN_BITBUCKET_USERNAME and ATLASSIAN_BITBUCKET_APP_PASSWORD before running.
#   2. Run: ./mcp-bitbucket-wrapper.sh [args]
#
# Environment overrides (optional):
#   BITBUCKET_DEFAULT_WORKSPACE (default: Guttmacher)
#   ATLASSIAN_BITBUCKET_USERNAME (overrides keychain)
#   ATLASSIAN_BITBUCKET_APP_PASSWORD (overrides keychain)
#
set -euo pipefail

SERVICE_NAME="bitbucket-mcp"
USERNAME_ACCOUNT="username"
PASSWORD_ACCOUNT="app-password"

get_keychain_value() {
  local account="$1"
  if [[ "$(uname)" == "Darwin" ]]; then
    security find-generic-password -s "$SERVICE_NAME" -a "$account" -w 2>/dev/null || return 1
  else
    return 1
  fi
}

# Get username from environment or keychain
if [[ -n "${ATLASSIAN_BITBUCKET_USERNAME:-}" ]]; then
  USERNAME="$ATLASSIAN_BITBUCKET_USERNAME"
else
  if [[ "$(uname)" == "Darwin" ]]; then
    if USERNAME=$(get_keychain_value "$USERNAME_ACCOUNT"); then
      true  # Successfully retrieved username from keychain
    else
      echo "Error: Could not retrieve Bitbucket username from Keychain (service '$SERVICE_NAME', account '$USERNAME_ACCOUNT')." >&2
      echo "Add it with: security add-generic-password -s '$SERVICE_NAME' -a '$USERNAME_ACCOUNT' -w '<username>'" >&2
      echo "Or set environment variable: export ATLASSIAN_BITBUCKET_USERNAME='<username>'" >&2
      exit 1
    fi
  else
    echo "Error: ATLASSIAN_BITBUCKET_USERNAME environment variable is not set and keychain is not available on non-macOS systems." >&2
    exit 1
  fi
fi

# Get app password from environment or keychain
if [[ -n "${ATLASSIAN_BITBUCKET_APP_PASSWORD:-}" ]]; then
  APP_PASS="$ATLASSIAN_BITBUCKET_APP_PASSWORD"
else
  if [[ "$(uname)" == "Darwin" ]]; then
    if APP_PASS=$(get_keychain_value "$PASSWORD_ACCOUNT"); then
      true  # Successfully retrieved password from keychain
    else
      echo "Error: Could not retrieve Bitbucket app password from Keychain (service '$SERVICE_NAME', account '$PASSWORD_ACCOUNT')." >&2
      echo "Add it with: security add-generic-password -s '$SERVICE_NAME' -a '$PASSWORD_ACCOUNT' -w '<app_password>'" >&2
      echo "Or set environment variable: export ATLASSIAN_BITBUCKET_APP_PASSWORD='<app_password>'" >&2
      exit 1
    fi
  else
    echo "Error: ATLASSIAN_BITBUCKET_APP_PASSWORD environment variable is not set and keychain is not available on non-macOS systems." >&2
    exit 1
  fi
fi

export ATLASSIAN_BITBUCKET_USERNAME="$USERNAME"
export ATLASSIAN_BITBUCKET_APP_PASSWORD="$APP_PASS"
export BITBUCKET_DEFAULT_WORKSPACE="${BITBUCKET_DEFAULT_WORKSPACE:-Guttmacher}"

exec npx -y @aashari/mcp-server-atlassian-bitbucket "$@"
