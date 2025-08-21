#!/usr/bin/env bash
# Atlassian (Local) MCP Server Wrapper (macOS / Linux)
# Securely launches the Sooperset Atlassian MCP server with API token from macOS Keychain or environment variables
#
# Container runtime setup required (macOS/Linux):
#   - Preferred (macOS): Install Colima (https://github.com/abiosoft/colima) and run: colima start
#   - You can override the runtime with DOCKER_COMMAND (docker, podman, nerdctl, etc.)
#
# Keychain setup (macOS):
#   If you prefer the CLI:
#       ( unset HISTFILE; stty -echo; printf "Enter Atlassian API token: "; read PW; stty echo; printf "\n"; \
#         security add-generic-password -s atlassian-mcp-local -a api-token -w "$PW"; \
#         unset PW )
#   If you prefer the Keychain Access GUI:
#       File > New Password Item...
#       Name: atlassian-mcp-local, Account: api-token, Password: <api_token>
#
# API Token creation:
#   1. Go to https://id.atlassian.com/manage-profile/security/api-tokens
#   2. Create API token for your Atlassian account
#   3. Store it securely in keychain or environment variable
#
# Usage:
#   1. Create keychain entry (see above) OR export ATLASSIAN_API_TOKEN before running.
#   2. Set ATLASSIAN_DOMAIN environment variable (set in JSON config).
#   3. Run: ./mcp-atlassian-local-wrapper.sh [args]
#
# Environment variables required:
#   ATLASSIAN_DOMAIN (required: e.g., "guttmacher.atlassian.net")
# Environment variables optional:
#   ATLASSIAN_API_TOKEN (overrides keychain)
#   ATLASSIAN_EMAIL (default: derived from current user)
#   ATLASSIAN_EMAIL (default: derived from current user)
#   AUTH_METHOD (default: "api_token")
#   DOCKER_COMMAND (default: "docker", alternative: "podman")
#   MCP_ATLASSIAN_IMAGE (default: "ghcr.io/sooperset/mcp-atlassian:latest")
#
set -euo pipefail

SERVICE_NAME="atlassian-mcp-local"
ACCOUNT_NAME="api-token"
DOCKER_COMMAND="${DOCKER_COMMAND:-docker}"
MCP_ATLASSIAN_IMAGE="${MCP_ATLASSIAN_IMAGE:-ghcr.io/sooperset/mcp-atlassian:latest}"
AUTH_METHOD="${AUTH_METHOD:-api_token}"

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
  
  # Check if the container runtime daemon is running (Colima exposes docker-compatible CLI once started)
  if ! "$DOCKER_COMMAND" info &> /dev/null; then
    echo "Error: $DOCKER_COMMAND daemon is not running." >&2
    echo "Start it with: 'colima start' (macOS) or start your docker/Podman service before using this wrapper." >&2
    exit 1
  fi
}

pull_image_if_needed() {
  echo "Checking for latest Atlassian MCP server image..." >&2
  if ! "$DOCKER_COMMAND" pull "$MCP_ATLASSIAN_IMAGE" >&2; then
    echo "Warning: Failed to pull latest image. Using local version if available." >&2
  fi
}

# Check container runtime availability
check_docker

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

# Pull latest image
pull_image_if_needed

# Set up environment variables for the container
DOCKER_ENV_ARGS=(
  -e "CONFLUENCE_URL=https://$ATLASSIAN_DOMAIN/wiki"
  -e "JIRA_URL=https://$ATLASSIAN_DOMAIN"
)

if [[ "$AUTH_METHOD" == "api_token" ]]; then
  DOCKER_ENV_ARGS+=(
    -e "CONFLUENCE_USERNAME=${ATLASSIAN_EMAIL}"
    -e "CONFLUENCE_API_TOKEN=$API_TOKEN"
    -e "JIRA_USERNAME=${ATLASSIAN_EMAIL}"
    -e "JIRA_API_TOKEN=$API_TOKEN"
  )
fi

# Launch the container in interactive mode with stdin/stdout
exec "$DOCKER_COMMAND" run --rm -i \
  "${DOCKER_ENV_ARGS[@]}" \
  "$MCP_ATLASSIAN_IMAGE" \
  "$@"
