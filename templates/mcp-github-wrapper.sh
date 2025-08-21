#!/usr/bin/env bash
set -euo pipefail

# Retrieve GitHub token from macOS Keychain (template uses 'GitHub' service)
GITHUB_TOKEN=$(security find-generic-password -s "GitHub" -a "$USER" -w 2>/dev/null || true)
if [ -z "${GITHUB_TOKEN}" ]; then
    echo "Error: Could not retrieve GitHub token from keychain" >&2
    echo "Ensure keychain item 'GitHub' exists and keychain is unlocked" >&2
    exit 1
fi

# Prefer local npm-installed CLI for fastest startup.
# Defaults can be overridden via environment variables.
NPM_PKG_NAME=${MCP_GITHUB_NPM_PKG:-github-mcp-server}
CLI_BIN_NAME=${MCP_GITHUB_CLI_BIN:-github-mcp-server}
DOCKER_IMAGE=${MCP_GITHUB_DOCKER_IMAGE:-ghcr.io/github/github-mcp-server:latest}

run_cli() {
  GITHUB_PERSONAL_ACCESS_TOKEN="${GITHUB_TOKEN}" exec "${CLI_BIN_NAME}" "$@"
}

# 1) If CLI already available, run it.
if command -v "${CLI_BIN_NAME}" >/dev/null 2>&1; then
  run_cli "$@"
fi

# 2) If npx available, try running the package via npx (no global install)
if command -v npx >/dev/null 2>&1; then
  GITHUB_PERSONAL_ACCESS_TOKEN="${GITHUB_TOKEN}" exec npx -y "${NPM_PKG_NAME}" "$@"
fi

# 3) Fallback to Docker using cached image (no network pulls at runtime)
exec docker run -i --rm --pull=never \
  -e "GITHUB_PERSONAL_ACCESS_TOKEN=${GITHUB_TOKEN}" \
  "${DOCKER_IMAGE}" "$@"
