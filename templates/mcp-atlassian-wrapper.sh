#!/usr/bin/env bash
# Atlassian (Local) MCP Server Wrapper (macOS / Linux)
# Securely launches the Sooperset Atlassian MCP server with API token from macOS Keychain or environment variables
# Startup order: local CLI on PATH -> npx (no global install, if package available) -> container (cached, --pull=never)
# No automatic npm -g installs to avoid interactive prompts in editors (VS Code, Claude Desktop).
# Env overrides: MCP_ATLASSIAN_CLI_BIN, MCP_ATLASSIAN_NPM_PKG, MCP_ATLASSIAN_IMAGE/DOCKER_COMMAND
# Logging note: All diagnostics/info are sent to stderr on purpose. MCP clients require
# stdout to contain only JSON-RPC (and headers). Any human text on stdout can break init.

set -euo pipefail

SERVICE_NAME="atlassian-mcp"
ACCOUNT_NAME="api-token"
DOCKER_COMMAND="${DOCKER_COMMAND:-docker}"
MCP_ATLASSIAN_IMAGE="${MCP_ATLASSIAN_IMAGE:-ghcr.io/sooperset/mcp-atlassian:latest}"
AUTH_METHOD="${AUTH_METHOD:-api_token}"
NPM_PKG_NAME=${MCP_ATLASSIAN_NPM_PKG:-@sooperset/mcp-atlassian}
CLI_BIN_NAME=${MCP_ATLASSIAN_CLI_BIN:-mcp-atlassian}

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

check_docker() {
  if ! command -v "$DOCKER_COMMAND" &> /dev/null; then
    echo "Error: $DOCKER_COMMAND is not installed or not in PATH." >&2
    echo "Please install Colima (macOS) or docker / Podman to use the local Atlassian MCP server." >&2
    exit 1
  fi
  if ! "$DOCKER_COMMAND" info &> /dev/null; then
    echo "Error: $DOCKER_COMMAND daemon is not running." >&2
    echo "Start it with: 'colima start' (macOS) or start your docker/Podman service before using this wrapper." >&2
    exit 1
  fi
}


# Domain is required from environment (set in JSON config)
if [[ -z "${ATLASSIAN_DOMAIN:-}" ]]; then
  echo "Error: ATLASSIAN_DOMAIN environment variable is required." >&2
  echo "This should be set in your agent configuration JSON file (e.g., 'guttmacher.atlassian.net')." >&2
  exit 1
fi

# Get API token from environment or keychain (for api_token auth method)
if [[ -n "${ATLASSIAN_API_TOKEN:-}" ]]; then
  API_TOKEN="$ATLASSIAN_API_TOKEN"
else
  if [[ "$(uname)" == "Darwin" ]]; then
    if ! API_TOKEN=$(get_keychain_password); then
      echo "Error: Could not retrieve Atlassian API token from Keychain (service '$SERVICE_NAME', account '$ACCOUNT_NAME')." >&2
      echo "Add it with: security add-generic-password -s '$SERVICE_NAME' -a '$ACCOUNT_NAME' -w '<api_token>'" >&2
      echo "Or set environment variable: export ATLASSIAN_API_TOKEN='<api_token>'" >&2
      echo "Create API token at: https://id.atlassian.com/manage-profile/security/api-tokens" >&2
      exit 1
    fi
  else
    echo "Error: ATLASSIAN_API_TOKEN is not set and macOS Keychain is unavailable on this platform." >&2
    echo "Set environment variable: export ATLASSIAN_API_TOKEN='<api_token>'" >&2
    echo "Create API token at: https://id.atlassian.com/manage-profile/security/api-tokens" >&2
    exit 1
  fi
fi

# Derive email if not provided (required for API token auth)
if [[ -z "${ATLASSIAN_EMAIL:-}" ]]; then
  ATLASSIAN_EMAIL="${USER}@${ATLASSIAN_DOMAIN//.atlassian.net/.com}"
  echo "Note: Using derived email '$ATLASSIAN_EMAIL'. Set ATLASSIAN_EMAIL to override." >&2
fi

run_cli() {
  CONFLUENCE_URL="https://${ATLASSIAN_DOMAIN}/wiki" \
  JIRA_URL="https://${ATLASSIAN_DOMAIN}" \
  CONFLUENCE_USERNAME="${ATLASSIAN_EMAIL}" \
  JIRA_USERNAME="${ATLASSIAN_EMAIL}" \
  CONFLUENCE_API_TOKEN="${API_TOKEN}" \
  JIRA_API_TOKEN="${API_TOKEN}" \
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

# Try npm-based CLI first (only if already installed) or via npx if resolvable
if command -v "${CLI_BIN_NAME}" >/dev/null 2>&1; then
  echo "Using Atlassian MCP via local CLI on PATH: ${CLI_BIN_NAME}" >&2
  run_cli "$@"
fi
if command -v npx >/dev/null 2>&1; then
  # Try to run via npx; on failure, fall back to container
  set +e
  echo "Using Atlassian MCP via npx package: ${NPM_PKG_NAME}@latest" >&2
  CONFLUENCE_URL="https://${ATLASSIAN_DOMAIN}/wiki" \
  JIRA_URL="https://${ATLASSIAN_DOMAIN}" \
  CONFLUENCE_USERNAME="${ATLASSIAN_EMAIL}" \
  JIRA_USERNAME="${ATLASSIAN_EMAIL}" \
  CONFLUENCE_API_TOKEN="${API_TOKEN}" \
  JIRA_API_TOKEN="${API_TOKEN}" \
  NPX_FLAGS=(-y)
  npx "${NPX_FLAGS[@]}" "${NPM_PKG_NAME}@latest" "$@" 2> >(cat >&2) | \
    awk 'BEGIN{IGNORECASE=1} { if ($0 ~ /^[[:space:]]*Content-(Length|Type):/ || $0 ~ /^[[:space:]]*$/ || $0 ~ /^[[:space:]]*[\[{]/) { print; fflush(); } else { print $0 > "/dev/stderr"; fflush("/dev/stderr"); } }'
  rc=${PIPESTATUS[0]}
  set -e
  if [ "$rc" -eq 0 ]; then
    exit 0
  else
    echo "Warning: npx ${NPM_PKG_NAME} failed with code $rc; falling back to container." >&2
  fi
fi

# Fallback to container runtime
check_docker

DOCKER_ENV_ARGS=(
  -e "NO_COLOR=1"
  -e "CONFLUENCE_URL=https://$ATLASSIAN_DOMAIN/wiki"
  -e "JIRA_URL=https://$ATLASSIAN_DOMAIN"
  -e "CONFLUENCE_USERNAME=${ATLASSIAN_EMAIL}"
  -e "CONFLUENCE_API_TOKEN=$API_TOKEN"
  -e "JIRA_USERNAME=${ATLASSIAN_EMAIL}"
  -e "JIRA_API_TOKEN=$API_TOKEN"
)

echo "Using Atlassian MCP via container image: ${MCP_ATLASSIAN_IMAGE}" >&2
"$DOCKER_COMMAND" run --rm -i --pull=never \
  "${DOCKER_ENV_ARGS[@]}" \
  "$MCP_ATLASSIAN_IMAGE" \
  "$@" 2> >(cat >&2) | \
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
