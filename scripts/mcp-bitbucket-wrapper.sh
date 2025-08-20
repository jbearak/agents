#!/usr/bin/env bash
# Bitbucket MCP Server Wrapper (macOS / Linux)
# Securely launches the Bitbucket MCP server with credentials from macOS Keychain (macOS) or environment variables (fallback)
#
# Keychain setup (macOS):
#   security add-generic-password -s "bitbucket-mcp" -a "<username>" -w "<app_password>"
#   (Or use Keychain Access GUI: New Password Item... Name: bitbucket-mcp, Account: <username>, Password: <app_password>)
# Usage:
#   1. Create keychain entry (see above) OR export ATLASSIAN_BITBUCKET_USERNAME and ATLASSIAN_BITBUCKET_APP_PASSWORD before running.
#   2. Run: ./mcp-bitbucket-wrapper.sh [args]
#
# Environment overrides (optional):
#   BITBUCKET_DEFAULT_WORKSPACE (default: Guttmacher)
#   ATLASSIAN_BITBUCKET_USERNAME (overrides keychain)
#   ATLASSIAN_BITBUCKET_APP_PASSWORD (overrides keychain)
#
set -euo pipefail

SERVICE_NAME="bitbucket-mcp"

get_keychain_credentials() {
  if [[ "$(uname)" != "Darwin" ]]; then
    return 1
  fi
  
  # Try to find any generic password for the service
  local keychain_info
  if keychain_info=$(security find-generic-password -s "$SERVICE_NAME" -g 2>&1); then
    # Extract username (account) from the output
    local username
    username=$(echo "$keychain_info" | grep "acct" | sed 's/.*"\(.*\)".*/\1/')
    
    # Get the password
    local password
    if password=$(security find-generic-password -s "$SERVICE_NAME" -a "$username" -w 2>/dev/null); then
      echo "$username:$password"
      return 0
    fi
  fi
  return 1
}

# Get credentials from environment or keychain
if [[ -n "${ATLASSIAN_BITBUCKET_USERNAME:-}" && -n "${ATLASSIAN_BITBUCKET_APP_PASSWORD:-}" ]]; then
  USERNAME="$ATLASSIAN_BITBUCKET_USERNAME"
  APP_PASS="$ATLASSIAN_BITBUCKET_APP_PASSWORD"
else
  if [[ "$(uname)" == "Darwin" ]]; then
    if credentials=$(get_keychain_credentials); then
      USERNAME="${credentials%%:*}"
      APP_PASS="${credentials#*:}"
    else
      echo "Error: Could not retrieve Bitbucket credentials from Keychain (service '$SERVICE_NAME')." >&2
      echo "Add them with: security add-generic-password -s '$SERVICE_NAME' -a '<username>' -w '<app_password>'" >&2
      echo "Or set environment variables: export ATLASSIAN_BITBUCKET_USERNAME='<username>' ATLASSIAN_BITBUCKET_APP_PASSWORD='<app_password>'" >&2
      exit 1
    fi
  else
    echo "Error: Environment variables ATLASSIAN_BITBUCKET_USERNAME and ATLASSIAN_BITBUCKET_APP_PASSWORD are not set and keychain is not available on non-macOS systems." >&2
    exit 1
  fi
fi

export ATLASSIAN_BITBUCKET_USERNAME="$USERNAME"
export ATLASSIAN_BITBUCKET_APP_PASSWORD="$APP_PASS"
export BITBUCKET_DEFAULT_WORKSPACE="${BITBUCKET_DEFAULT_WORKSPACE:-Guttmacher}"

exec npx -y @aashari/mcp-server-atlassian-bitbucket "$@"
