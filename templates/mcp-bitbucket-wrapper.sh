#!/usr/bin/env bash
# Bitbucket MCP Server Wrapper (macOS / Linux)
# Securely launches the Bitbucket MCP server with app password from macOS Keychain (macOS) or environment variables (fallback)
# Prefer npm-installed CLI for fastest startup, with optional Docker fallback.

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

export ATLASSIAN_BITBUCKET_USERNAME
export ATLASSIAN_BITBUCKET_APP_PASSWORD="${APP_PASS}"
export BITBUCKET_DEFAULT_WORKSPACE="${BITBUCKET_DEFAULT_WORKSPACE:-Guttmacher}"

# Defaults can be overridden via environment variables
NPM_PKG_NAME=${MCP_BITBUCKET_NPM_PKG:-@aashari/mcp-server-atlassian-bitbucket}
CLI_BIN_NAME=${MCP_BITBUCKET_CLI_BIN:-mcp-atlassian-bitbucket}
DOCKER_IMAGE=${MCP_BITBUCKET_DOCKER_IMAGE:-}

run_cli() {
  exec "${CLI_BIN_NAME}" "$@"
}

# 1) If CLI already available, run it.
if command -v "${CLI_BIN_NAME}" >/dev/null 2>&1; then
  run_cli "$@"
fi

# 2) If npm available, try one-time global install, then run.
if command -v npm >/dev/null 2>&1; then
  if ! npm -g ls "${NPM_PKG_NAME}" >/dev/null 2>&1; then
    npm -g install "${NPM_PKG_NAME}" >/dev/null 2>&1 || true
  fi
  if command -v "${CLI_BIN_NAME}" >/dev/null 2>&1; then
    run_cli "$@"
  fi
fi

# 3) Try npx as a fallback if available
if command -v npx >/dev/null 2>&1; then
  exec npx -y "${NPM_PKG_NAME}" "$@"
fi

# 4) Optional Docker fallback if image is specified
if [ -n "${DOCKER_IMAGE}" ] && command -v docker >/dev/null 2>&1; then
  exec docker run -i --rm --pull=never \
    -e "ATLASSIAN_BITBUCKET_USERNAME=${ATLASSIAN_BITBUCKET_USERNAME}" \
    -e "ATLASSIAN_BITBUCKET_APP_PASSWORD=${APP_PASS}" \
    -e "BITBUCKET_DEFAULT_WORKSPACE=${BITBUCKET_DEFAULT_WORKSPACE}" \
    "${DOCKER_IMAGE}" "$@"
fi

echo "Error: Bitbucket MCP CLI not found and no viable fallback (npm/npx/docker) available." >&2
exit 1
