#!/usr/bin/env bash
# Atlassian (Local) MCP Server Wrapper (macOS / Linux)
# Securely launches the Sooperset Atlassian MCP server with API token from macOS Keychain or environment variables
# Startup order: container only (Docker-based MCP server)
# The upstream sooperset/mcp-atlassian only provides Docker container deployment
# Env overrides: MCP_ATLASSIAN_IMAGE/DOCKER_COMMAND
# Logging note: All diagnostics/info are sent to stderr on purpose. MCP clients require
# stdout to contain only JSON-RPC (and headers). Any human text on stdout can break init.

set -euo pipefail

SERVICE_NAME="atlassian-mcp"
ACCOUNT_NAME="api-token"
DOCKER_COMMAND="${DOCKER_COMMAND:-docker}"
MCP_ATLASSIAN_IMAGE="${MCP_ATLASSIAN_IMAGE:-ghcr.io/sooperset/mcp-atlassian:latest}"
AUTH_METHOD="${AUTH_METHOD:-api_token}"
# Note: sooperset/mcp-atlassian only supports Docker containers

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


# Domain default if unset
if [[ -z "${ATLASSIAN_DOMAIN:-}" ]]; then
  ATLASSIAN_DOMAIN="guttmacher.atlassian.net"
  echo "Note: ATLASSIAN_DOMAIN was not set; defaulting to '${ATLASSIAN_DOMAIN}'." >&2
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

# Derive email if not provided (prefer env var -> git -> username@derived .org)
if [[ -z "${ATLASSIAN_EMAIL:-}" ]]; then
  GIT_EMAIL=""
  if command -v git >/dev/null 2>&1; then
    GIT_EMAIL="$(git config --get user.email 2>/dev/null || true)"
  fi
  if [[ -n "$GIT_EMAIL" ]]; then
    ATLASSIAN_EMAIL="$GIT_EMAIL"
  else
    ATLASSIAN_EMAIL="${USER}@${ATLASSIAN_DOMAIN//.atlassian.net/.org}"
  fi
  echo "Note: Using derived email '$ATLASSIAN_EMAIL'. Set ATLASSIAN_EMAIL to override." >&2
fi

# run_cli function removed - sooperset/mcp-atlassian only supports Docker containers

# Use container runtime (only option available)
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

# Ensure image present (auto-pull if missing)
if ! "$DOCKER_COMMAND" image inspect "${MCP_ATLASSIAN_IMAGE}" >/dev/null 2>&1; then
  echo "Pulling Atlassian MCP Docker image: ${MCP_ATLASSIAN_IMAGE}" >&2
  if ! "$DOCKER_COMMAND" pull "${MCP_ATLASSIAN_IMAGE}" >&2; then
    echo "Error: failed to pull image: ${MCP_ATLASSIAN_IMAGE}" >&2
    exit 1
  fi
  echo "Pulled Atlassian MCP Docker image successfully: ${MCP_ATLASSIAN_IMAGE}" >&2
fi

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
