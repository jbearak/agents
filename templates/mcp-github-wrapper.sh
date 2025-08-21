#!/usr/bin/env bash
# Startup order: local CLI on PATH -> npx (no global install) -> container (cached, --pull=never)
# No automatic npm -g installs to avoid interactive prompts in editors (VS Code, Claude Desktop).
# Env overrides: MCP_GITHUB_CLI_BIN, MCP_GITHUB_NPM_PKG, MCP_GITHUB_DOCKER_IMAGE, DOCKER_COMMAND
# Logging note: We write diagnostics/info to stderr so stdout remains JSON-only for MCP.
# Any banner/progress on stdout can break the JSON-RPC initialize handshake.
set -euo pipefail

# --- Configurable defaults ---
SERVICE_NAME="github-mcp"
ACCOUNT_NAME="$USER"
DOCKER_COMMAND="${DOCKER_COMMAND:-docker}"
NPM_PKG_NAME="${MCP_GITHUB_NPM_PKG:-github-mcp-server}"
CLI_BIN_NAME="${MCP_GITHUB_CLI_BIN:-github-mcp-server}"
DOCKER_IMAGE="${MCP_GITHUB_DOCKER_IMAGE:-ghcr.io/github/github-mcp-server:latest}"

# --- Helper Functions ---
check_docker_daemon() {
  if ! "$DOCKER_COMMAND" info &> /dev/null; then
    echo "Error: Docker daemon ('$DOCKER_COMMAND') is not running." >&2
    echo "Please start your container runtime (e.g., colima start, podman machine start, or Docker Desktop)." >&2
    return 1
  fi
}

# --- Main Logic ---

# 1. Obtain GitHub Token (prefer env var, fallback to macOS Keychain)
GITHUB_TOKEN="${GITHUB_PERSONAL_ACCESS_TOKEN:-}"
if [ -z "${GITHUB_TOKEN}" ]; then
  if [[ "$(uname)" == "Darwin" ]]; then
    GITHUB_TOKEN=$(security find-generic-password -s "$SERVICE_NAME" -a "$ACCOUNT_NAME" -w 2>/dev/null || true)
  fi
fi
if [ -z "${GITHUB_TOKEN}" ]; then
  echo "Error: GitHub token not found." >&2
  echo "Set GITHUB_PERSONAL_ACCESS_TOKEN, or on macOS, create a Keychain item:" >&2
  echo "  security add-generic-password -s '$SERVICE_NAME' -a '$ACCOUNT_NAME' -w '<token>'" >&2
  exit 1
fi

# 2. Set common environment for child processes to keep stdout clean
export NO_COLOR=1
export NPM_CONFIG_LOGLEVEL=silent
export npm_config_loglevel=silent
export NPM_CONFIG_FUND=false
export NPM_CONFIG_AUDIT=false
export NO_UPDATE_NOTIFIER=1
export ADBLOCK=1
export GITHUB_PERSONAL_ACCESS_TOKEN="$GITHUB_TOKEN"

# --- Startup Paths ---

# 1) Prefer Docker for reliability if available
if command -v "$DOCKER_COMMAND" >/dev/null 2>&1; then
  if check_docker_daemon; then
    echo "Using GitHub MCP via Docker image: ${DOCKER_IMAGE}" >&2
    "$DOCKER_COMMAND" run -i --rm --pull=never \
      -e NO_COLOR -e GITHUB_PERSONAL_ACCESS_TOKEN \
      "${DOCKER_IMAGE}" "$@" 2> >(cat >&2) | \
      awk 'BEGIN{IGNORECASE=1} { if ($0 ~ /^[[:space:]]*Content-(Length|Type):/ || $0 ~ /^[[:space:]]*$/ || $0 ~ /^[[:space:]]*[\[{]/) { print; fflush(); } else { print $0 > "/dev/stderr"; fflush("/dev/stderr"); } }'
    exit ${PIPESTATUS[0]}
  fi
fi

# 2) Fallback to npx
if command -v npx >/dev/null 2>&1; then
  echo "Using GitHub MCP via npx package: ${NPM_PKG_NAME}@latest" >&2
  npx -y "${NPM_PKG_NAME}@latest" "$@" 2> >(cat >&2) | \
    awk 'BEGIN{IGNORECASE=1; started=0; saw=0} { if(started==0){if($0 ~ /^[[:space:]]*Content-(Length|Type):/){print;fflush();saw=1;next}if(saw && $0~/^[[:space:]]*$/){print;fflush();started=1;next}if($0~/^[[:space:]]*\{/ || $0~/^[[:space:]]*\[/){print;fflush();started=1;next}print $0 > "/dev/stderr";fflush("/dev/stderr");next} print;fflush() }'
  exit ${PIPESTATUS[0]}
fi

# 3) Last resort: local CLI
if command -v "${CLI_BIN_NAME}" >/dev/null 2>&1; then
  echo "Using GitHub MCP via local CLI on PATH: ${CLI_BIN_NAME}" >&2
  "${CLI_BIN_NAME}" "$@" 2> >(cat >&2) | \
    awk 'BEGIN{IGNORECASE=1} { if ($0 ~ /^[[:space:]]*Content-(Length|Type):/ || $0 ~ /^[[:space:]]*$/ || $0 ~ /^[[:space:]]*[\[{]/) { print; fflush(); } else { print $0 > "/dev/stderr"; fflush("/dev/stderr"); } }'
  exit ${PIPESTATUS[0]}
fi

echo "Error: Could not start GitHub MCP server. No viable startup path found (Docker, npx, or local CLI)." >&2
exit 1
exit 1
