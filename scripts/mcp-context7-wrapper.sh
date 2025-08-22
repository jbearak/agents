#!/usr/bin/env bash
# Context7 MCP Server Wrapper (macOS / Linux)
# Launches the Context7 MCP server using installed npm package or fallback to npx
# Startup order: installed npm package -> npx
# Env overrides: NPM_PKG_CONTEXT7/NODE_ENV
# Logging note: All diagnostics/info are sent to stderr on purpose. MCP clients require
# stdout to contain only JSON-RPC (and headers). Any human text on stdout can break init.

set -euo pipefail

NPM_PKG_CONTEXT7="${NPM_PKG_CONTEXT7:-@upstash/context7-mcp}"
NODE_ENV="${NODE_ENV:-production}"

# Keep stdout clean when npm/npx is used
export NO_COLOR=1
export NPM_CONFIG_LOGLEVEL=silent
export npm_config_loglevel=silent
export NPM_CONFIG_FUND=false
export NPM_CONFIG_AUDIT=false
export NO_UPDATE_NOTIFIER=1
export ADBLOCK=1

check_node() {
  if ! command -v node &> /dev/null; then
    echo "Error: Node.js is not installed or not in PATH." >&2
    echo "Please install Node.js to use the Context7 MCP server." >&2
    exit 1
  fi
}

check_npm() {
  if ! command -v npm &> /dev/null; then
    echo "Error: npm is not installed or not in PATH." >&2
    echo "Please install npm to use the Context7 MCP server." >&2
    exit 1
  fi
}

# Check if npm package is globally installed
is_package_installed() {
  npm list -g "$NPM_PKG_CONTEXT7" &> /dev/null
}

run_installed() {
  local cli_path
  cli_path=$(npm list -g "$NPM_PKG_CONTEXT7" --parseable 2>/dev/null | head -1)
  if [[ -n "$cli_path" && -d "$cli_path" ]]; then
    # Find the main entry point
    local main_script="$cli_path/dist/index.js"
    if [[ -f "$main_script" ]]; then
      echo "Using installed Context7 MCP package: $NPM_PKG_CONTEXT7" >&2
      node "$main_script" "$@" 2> >(cat >&2) | \
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
      return ${PIPESTATUS[0]}
    fi
  fi
  return 1
}

run_npx() {
  if ! command -v npx &> /dev/null; then
    echo "Error: npx is not available." >&2
    return 1
  fi
  echo "Using Context7 MCP via npx: $NPM_PKG_CONTEXT7@latest" >&2
  npx -y "$NPM_PKG_CONTEXT7@latest" "$@" 2> >(cat >&2) | \
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
}

# Main execution logic
check_node
check_npm

# Try installed package first, then fallback to npx
if is_package_installed && run_installed "$@"; then
  exit 0
else
  echo "Note: $NPM_PKG_CONTEXT7 not found globally installed, falling back to npx..." >&2
  if run_npx "$@"; then
    exit 0
  else
    echo "Error: Failed to run Context7 MCP server via both installed package and npx." >&2
    echo "Try installing globally with: npm install -g $NPM_PKG_CONTEXT7@latest" >&2
    exit 1
  fi
fi
