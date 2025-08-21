#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Prefer repo-local python3
PY=${PYTHON:-python3}
exec "$PY" "$SCRIPT_DIR/smoke_mcp_wrappers.py" "$@"
