#!/usr/bin/env bash
# GitHub MCP Server wrapper - Docker version
# Uses the official GitHub MCP server Docker image
# Env overrides: MCP_GITHUB_DOCKER_IMAGE, DOCKER_COMMAND
# Logging note: We write diagnostics/info to stderr so stdout remains JSON-only for MCP.
# Any banner/progress on stdout can break the JSON-RPC initialize handshake.
set -euo pipefail

# --- Configurable defaults ---
SERVICE_NAME="github-mcp"
ACCOUNT_NAME="token"
DOCKER_COMMAND="${DOCKER_COMMAND:-docker}"
DOCKER_IMAGE="${MCP_GITHUB_DOCKER_IMAGE:-ghcr.io/github/github-mcp-server:latest}"
REMOTE_MCP_URL="${GITHUB_MCP_REMOTE_URL:-https://api.githubcopilot.com/mcp/}"

# --- Helper Functions ---
check_docker_daemon() {
  if ! "$DOCKER_COMMAND" info &> /dev/null; then
    echo "Error: Docker daemon ('$DOCKER_COMMAND') is not running." >&2
    echo "Please start your container runtime (e.g., 'colima start')." >&2
    return 1
  fi
}

use_remote_server() {
  echo "Falling back to remote GitHub MCP server: $REMOTE_MCP_URL" >&2
  
  # Check if curl is available
  if ! command -v curl >/dev/null 2>&1; then
    echo "Error: curl not found. Cannot connect to remote server." >&2
    echo "Please install Docker/Podman or curl to use GitHub MCP server." >&2
    exit 1
  fi
  
  # For MCP over HTTP, we need to handle the initialize handshake properly
  # Read the first message (should be initialize request)
  local input_line
  read -r input_line
  
  # Send initialize request to remote server and get response
  response=$(echo "$input_line" | curl -s -S \
    -H "Authorization: Bearer $GITHUB_TOKEN" \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -X POST \
    -d @- \
    "$REMOTE_MCP_URL" 2>/dev/null)
  
  if [ $? -eq 0 ] && [ -n "$response" ]; then
    echo "$response"
    # Continue processing additional messages
    while read -r input_line; do
      if [ -n "$input_line" ]; then
        response=$(echo "$input_line" | curl -s -S \
          -H "Authorization: Bearer $GITHUB_TOKEN" \
          -H "Content-Type: application/json" \
          -H "Accept: application/json" \
          -X POST \
          -d @- \
          "$REMOTE_MCP_URL" 2>/dev/null)
        if [ $? -eq 0 ] && [ -n "$response" ]; then
          echo "$response"
        fi
      fi
    done
  else
    echo "Error: Failed to connect to remote GitHub MCP server." >&2
    echo "Please check your GITHUB_PERSONAL_ACCESS_TOKEN and network connection." >&2
    exit 1
  fi
}


# --- Main Logic ---

# 1. Obtain GitHub Token (prefer env var, fallback to macOS Keychain)
GITHUB_TOKEN="${GITHUB_PERSONAL_ACCESS_TOKEN:-}"
if [ -z "${GITHUB_TOKEN}" ]; then
  if [[ "$(uname)" == "Darwin" ]]; then
    # Try both common service names: 'github-mcp' (wrapper default) and 'GitHub' (docs/older installs)
    for svc in "$SERVICE_NAME" "GitHub"; do
      GITHUB_TOKEN=$(security find-generic-password -s "$svc" -a "$ACCOUNT_NAME" -w 2>/dev/null || true)
      if [ -n "$GITHUB_TOKEN" ]; then
        break
      fi
    done
  fi
fi
if [ -z "${GITHUB_TOKEN}" ]; then
  echo "Error: GitHub token not found." >&2
  echo "Set GITHUB_PERSONAL_ACCESS_TOKEN, or add a macOS Keychain item: service 'github-mcp' (or 'GitHub'), account 'token'." >&2
  echo "macOS (secure prompt):" >&2
  echo "  ( unset HISTFILE; stty -echo; printf 'Enter GitHub PAT: '; read PW; stty echo; printf '\n'; security add-generic-password -s github-mcp -a token -w \"$PW\"; unset PW )" >&2
  exit 1
fi

# 2. Set environment for Docker
export GITHUB_PERSONAL_ACCESS_TOKEN="$GITHUB_TOKEN"

# 3. Ensure stdio transport unless explicitly provided
NEEDS_STDIO=1
for a in "$@"; do
  case "$a" in
    stdio|--stdio|--sse|--transport=*|--http*|--sse*|--port|--host)
      NEEDS_STDIO=0
      ;;
  esac
done
if [ $NEEDS_STDIO -eq 1 ]; then
  set -- stdio "$@"
fi

# --- Startup ---

# Check if Docker is available
if ! command -v "$DOCKER_COMMAND" >/dev/null 2>&1; then
  echo "Error: Docker not found. Please install Docker or set DOCKER_COMMAND to point to your container runtime." >&2
  echo "Attempting to use remote server fallback..." >&2
  use_remote_server
fi

# Check if Docker daemon is running
if ! check_docker_daemon; then
  echo "Attempting to use remote server fallback..." >&2
  use_remote_server
fi

# Ensure image present (auto-pull if missing)
if ! "$DOCKER_COMMAND" image inspect "${DOCKER_IMAGE}" >/dev/null 2>&1; then
  echo "Pulling GitHub MCP Docker image: ${DOCKER_IMAGE}" >&2
  if ! "$DOCKER_COMMAND" pull "${DOCKER_IMAGE}" >&2; then
    echo "Error: failed to pull image: ${DOCKER_IMAGE}" >&2
    echo "Attempting to use remote server fallback..." >&2
    use_remote_server
  fi
  echo "Pulled GitHub MCP Docker image successfully: ${DOCKER_IMAGE}" >&2
fi

echo "Using GitHub MCP via Docker image: ${DOCKER_IMAGE}" >&2

# Run the Docker container
"$DOCKER_COMMAND" run -i --rm \
  -e GITHUB_PERSONAL_ACCESS_TOKEN \
  "${DOCKER_IMAGE}" "$@" 2> >(cat >&2)

exit $?
