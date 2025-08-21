#!/usr/bin/env bash
# Startup order: local CLI on PATH -> npx (no global install) -> container (cached, --pull=never)
# No automatic npm -g installs to avoid interactive prompts in editors (VS Code, Claude Desktop).
# Env overrides: MCP_GITHUB_CLI_BIN, MCP_GITHUB_NPM_PKG, MCP_GITHUB_DOCKER_IMAGE
set -euo pipefail

# Retrieve GitHub token from macOS Keychain (template uses 'GitHub' service)
# Prefer env var if set; otherwise try Keychain (non-interactive)
GITHUB_TOKEN="${GITHUB_PERSONAL_ACCESS_TOKEN:-}"
if [ -z "${GITHUB_TOKEN}" ]; then
  GITHUB_TOKEN=$(security find-generic-password -s "GitHub" -a "$USER" -w 2>/dev/null || true)
fi
if [ -z "${GITHUB_TOKEN}" ]; then
  echo "Error: GitHub token not found." >&2
  echo "Set GITHUB_PERSONAL_ACCESS_TOKEN in the environment used by the editor," >&2
  echo "or create an unlocked Keychain item: security add-generic-password -s 'GitHub' -a '$USER' -w '<token>'" >&2
  exit 1
fi

# Prefer local npm-installed CLI for fastest startup.
# Defaults can be overridden via environment variables.
NPM_PKG_NAME=${MCP_GITHUB_NPM_PKG:-github-mcp-server}
CLI_BIN_NAME=${MCP_GITHUB_CLI_BIN:-github-mcp-server}
DOCKER_IMAGE=${MCP_GITHUB_DOCKER_IMAGE:-ghcr.io/github/github-mcp-server:latest}

# Keep stdout clean: request silent behavior from npm/npx and tools
export NO_COLOR=1
export NPM_CONFIG_LOGLEVEL=silent
export npm_config_loglevel=silent
export NPM_CONFIG_FUND=false
export NPM_CONFIG_AUDIT=false
export NO_UPDATE_NOTIFIER=1
export ADBLOCK=1

run_cli() {
  # Stream stdout through a JSON-only filter that forwards only lines starting with '{'
  GITHUB_PERSONAL_ACCESS_TOKEN="${GITHUB_TOKEN}" \
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

# 1) Prefer Docker (official image) for reliability
if command -v docker >/dev/null 2>&1; then
  echo "Using GitHub MCP via Docker image: ${DOCKER_IMAGE}" >&2
  docker run -i --rm --pull=never \
    -e "NO_COLOR=1" \
    -e "GITHUB_PERSONAL_ACCESS_TOKEN=${GITHUB_TOKEN}" \
    "${DOCKER_IMAGE}" "$@" 2> >(cat >&2) | \
    awk 'BEGIN{IGNORECASE=1} { if ($0 ~ /^[[:space:]]*Content-(Length|Type):/ || $0 ~ /^[[:space:]]*$/ || $0 ~ /^[[:space:]]*[\[{]/) { print; fflush(); } else { print $0 > "/dev/stderr"; fflush("/dev/stderr"); } }'
  exit ${PIPESTATUS[0]}
fi

# 2) If npx available, try running the package via npx (no global install)
if command -v npx >/dev/null 2>&1; then
  echo "Using GitHub MCP via npx package: ${NPM_PKG_NAME}@latest" >&2
  NPX_FLAGS=(-y)
  # Route any non-JSON npx preamble to stderr and pass only JSON-looking lines to stdout
  GITHUB_PERSONAL_ACCESS_TOKEN="${GITHUB_TOKEN}" \
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

# 3) As a last resort, try a locally installed CLI (may be a different tool if names conflict)
if command -v "${CLI_BIN_NAME}" >/dev/null 2>&1; then
  echo "Using GitHub MCP via local CLI on PATH: ${CLI_BIN_NAME}" >&2
  run_cli "$@"
fi

echo "Error: Could not start GitHub MCP server via docker, npx, or local CLI." >&2
exit 1
