#!/usr/bin/env bash
# Bitbucket MCP Server Wrapper (macOS / Linux)
# Securely launches the Bitbucket MCP server with app password from macOS Keychain (macOS) or environment variables (fallback)
# Startup order: local CLI on PATH -> npx (no global install) -> container (cached, --pull=never if image set)
# No automatic npm -g installs to avoid interactive prompts in editors (VS Code, Claude Desktop).
# Env overrides: MCP_BITBUCKET_CLI_BIN, MCP_BITBUCKET_NPM_PKG, MCP_BITBUCKET_DOCKER_IMAGE
# Logging note: All diagnostics/info are sent to stderr intentionally. MCP clients expect
# stdout to be pure JSON-RPC; human-readable text on stdout can break initialization.

set -euo pipefail

SERVICE_NAME="bitbucket-mcp"
ACCOUNT_NAME="app-password"

# Keep stdout clean when npm/npx is used
export NO_COLOR=1
export NPM_CONFIG_LOGLEVEL=silent
export npm_config_loglevel=silent
export NPM_CONFIG_FUND=false
export NPM_CONFIG_AUDIT=false
export NO_UPDATE_NOTIFIER=1
export ADBLOCK=1

get_keychain_password() {
  if [[ "$(uname)" != "Darwin" ]]; then
    return 1
  fi
  security find-generic-password -s "$SERVICE_NAME" -a "$ACCOUNT_NAME" -w 2>/dev/null || return 1
}

# Username: never prompt; derive from git email prefix when missing; otherwise require explicit value
if [[ -z "${ATLASSIAN_BITBUCKET_USERNAME:-}" ]]; then
  if command -v git >/dev/null 2>&1; then
    git_email="$(git config --get user.email 2>/dev/null || true)"
  else
    git_email=""
  fi
  if [[ -n "$git_email" ]]; then
    ATLASSIAN_BITBUCKET_USERNAME="${git_email%@*}"
    echo "Note: Using Bitbucket username '${ATLASSIAN_BITBUCKET_USERNAME}' derived from git user.email. Set ATLASSIAN_BITBUCKET_USERNAME to override." >&2
  else
    echo "Error: ATLASSIAN_BITBUCKET_USERNAME is not set and could not be derived. Set it explicitly or configure 'git config user.email'." >&2
    exit 1
  fi
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
  "${CLI_BIN_NAME}" "$@" 2> >(cat >&2) | \
awk 'BEGIN{IGNORECASE=1}
{
  if ($0 ~ /^[[:space:]]*Content-(Length|Type):/ || $0 ~ /^[[:space:]]*$/ || $0 ~ /^[[:space:]]*\{/ || $0 ~ /^[[:space:]]*\[[[:space:]]*(\"|\{|\[|[0-9-]|t|f|n|\])/) {
    print; fflush();
  } else {
    print $0 > "/dev/stderr"; fflush("/dev/stderr");
  }
}'
  exit ${PIPESTATUS[0]}
}

# 1) If CLI already available, run it.
if command -v "${CLI_BIN_NAME}" >/dev/null 2>&1; then
  echo "Using Bitbucket MCP via local CLI on PATH: ${CLI_BIN_NAME}" >&2
  run_cli "$@"
fi

# 2) Try npx as a fallback if available (no global install) as quietly as possible
if command -v npx >/dev/null 2>&1; then
  echo "Using Bitbucket MCP via npx package: ${NPM_PKG_NAME}@latest" >&2
  # Keep flags minimal to avoid incompatibilities across npx versions
  NPX_FLAGS=(-y)
  npx "${NPX_FLAGS[@]}" "${NPM_PKG_NAME}@latest" "$@" 2> >(cat >&2) | \
awk 'BEGIN{IGNORECASE=1; started=0; saw=0}
{
  if (started==0) {
    if ($0 ~ /^[[:space:]]*Content-(Length|Type):/) { print; fflush(); saw=1; next }
    if (saw && $0 ~ /^[[:space:]]*$/) { print; fflush(); started=1; next }
    if ($0 ~ /^[[:space:]]*\{/) { print; fflush(); started=1; next }
    if ($0 ~ /^[[:space:]]*\[[[:space:]]*(\"|\{|\[|[0-9-]|t|f|n|\])/) { print; fflush(); started=1; next }
    print $0 > "/dev/stderr"; fflush("/dev/stderr"); next
  }
  print; fflush();
}'
  exit ${PIPESTATUS[0]}
fi

# 3) Optional Docker fallback if image is specified
if [ -n "${DOCKER_IMAGE}" ] && command -v docker >/dev/null 2>&1; then
# Ensure image present (auto-pull if missing)
if ! docker image inspect "${DOCKER_IMAGE}" >/dev/null 2>&1; then
  echo "Pulling Bitbucket MCP Docker image: ${DOCKER_IMAGE}" >&2
  if ! docker pull "${DOCKER_IMAGE}" >&2; then
    echo "Error: failed to pull image: ${DOCKER_IMAGE}" >&2
    exit 1
  fi
fi

echo "Using Bitbucket MCP via docker image: ${DOCKER_IMAGE}" >&2
  docker run -i --rm --pull=never \
    -e "NO_COLOR=1" \
    -e "ATLASSIAN_BITBUCKET_USERNAME=${ATLASSIAN_BITBUCKET_USERNAME}" \
    -e "ATLASSIAN_BITBUCKET_APP_PASSWORD=${APP_PASS}" \
    -e "BITBUCKET_DEFAULT_WORKSPACE=${BITBUCKET_DEFAULT_WORKSPACE}" \
    "${DOCKER_IMAGE}" "$@" 2> >(cat >&2) | \
    awk '{ if ($0 ~ /^[[:space:]]*\{/) { print; fflush(); } else { print $0 > "/dev/stderr"; fflush("/dev/stderr"); } }'
  exit ${PIPESTATUS[0]}
fi

echo "Error: Bitbucket MCP CLI not found and no viable fallback (npm/npx/docker) available." >&2
exit 1
