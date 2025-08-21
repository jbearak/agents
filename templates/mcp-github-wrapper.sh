#!/usr/bin/env bash
# Startup order: local CLI on PATH -> npx (no global install) -> container (cached, --pull=never)
# No automatic npm -g installs to avoid interactive prompts in editors (VS Code, Claude Desktop).
# Env overrides: MCP_GITHUB_CLI_BIN, MCP_GITHUB_NPM_PKG, MCP_GITHUB_DOCKER_IMAGE
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
    awk 'BEGIN{IGNORECASE=1} { if ($0 ~ /^[[:space:]]*Content-(Length|Type):/ || $0 ~ /^[[:space:]]*$/ || $0 ~ /^[[:space:]]*[\[{]/) { print; fflush(); } else { print $0 > "/dev/stderr"; fflush("/dev/stderr"); } }'
:]]*[\[{]/) { print; fflush(); } else { print $0 > "/dev/stderr"; fflush("/dev/stderr"); } }'
  exit ${PIPESTATUS[0]}
}

# 1) If CLI already available, run it.
if command -v "${CLI_BIN_NAME}" >/dev/null 2>&1; then
  run_cli "$@"
fi

# 2) If npx available, try running the package via npx (no global install) as quietly as possible
if command -v npx >/dev/null 2>&1; then
  # Try to detect --quiet support and add it if available
  NPX_FLAGS=(-y)
  if npx --help 2>/dev/null | grep -q "--quiet"; then
    NPX_FLAGS+=(--quiet)
  fi
  # Route any non-JSON npx preamble to stderr and pass only JSON-looking lines to stdout
  # This is a pragmatic stream filter until upstream guarantees pure JSON on stdout.
  GITHUB_PERSONAL_ACCESS_TOKEN="${GITHUB_TOKEN}" \
    npx "${NPX_FLAGS[@]}" "${NPM_PKG_NAME}" "$@" 2> >(cat >&2) | \
    awk '{ if ($0 ~ /^[[:space:]]*\{/) { print; fflush(); } else { print $0 > "/dev/stderr"; fflush("/dev/stderr"); } }'
  exit ${PIPESTATUS[0]}
fi

# 3) Fallback to Docker using cached image (no network pulls at runtime)
docker run -i --rm --pull=never \
  -e "NO_COLOR=1" \
  -e "GITHUB_PERSONAL_ACCESS_TOKEN=${GITHUB_TOKEN}" \
  "${DOCKER_IMAGE}" "$@" 2> >(cat >&2) | \
  awk 'BEGIN{IGNORECASE=1} { if ($0 ~ /^[[:space:]]*Content-(Length|Type):/ || $0 ~ /^[[:space:]]*$/ || $0 ~ /^[[:space:]]*[\[{]/) { print; fflush(); } else { print $0 > "/dev/stderr"; fflush("/dev/stderr"); } }'
exit ${PIPESTATUS[0]}
