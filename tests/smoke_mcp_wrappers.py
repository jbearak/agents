#!/usr/bin/env python3
import argparse
import json
import os
import re
import signal
import subprocess
import sys
import time
from pathlib import Path

ALLOWED_PATTERNS = [
    re.compile(r"^\s*$"),  # blank
    re.compile(r"^\s*Content-(Length|Type):", re.I),  # JSON-RPC headers
    re.compile(r"^\s*\{"),  # JSON object start
    re.compile(r"^\s*\[\s*(\"|\{|\[|[0-9-]|t|f|n|\])"),  # JSON array start
]

DEFAULT_WRAPPERS = [
    "scripts/mcp-github-wrapper.sh",
    "scripts/mcp-bitbucket-wrapper.sh",
    "scripts/mcp-atlassian-wrapper.sh",
]

BIN_WRAPPERS = [
    str(Path.home() / "bin/mcp-github-wrapper.sh"),
    str(Path.home() / "bin/mcp-bitbucket-wrapper.sh"),
    str(Path.home() / "bin/mcp-atlassian-wrapper.sh"),
]


def looks_allowed(line: str) -> bool:
    for pat in ALLOWED_PATTERNS:
        if pat.search(line):
            return True
    # As a last resort, allow if it parses as JSON by itself
    try:
        json.loads(line)
        return True
    except Exception:
        return False


def run_with_timeout(cmd, cwd: Path, env: dict, timeout_seconds: float):
    # Start the process in its own session so we can kill the whole group
    proc = subprocess.Popen(
        cmd,
        cwd=str(cwd),
        env=env,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        start_new_session=True,
    )
    try:
        out, err = proc.communicate(timeout=timeout_seconds)
        return proc.returncode, out, err
    except subprocess.TimeoutExpired:
        # Kill the whole process group
        os.killpg(proc.pid, signal.SIGTERM)
        try:
            out, err = proc.communicate(timeout=2)
        except Exception:
            out, err = "", ""
        return None, out, err


def smoke_one(wrapper_path: Path, timeout: float) -> tuple[bool, str]:
    if not wrapper_path.exists():
        return True, f"SKIP (missing): {wrapper_path}"

    # Minimize noise from npm/npx and CLIs
    env = os.environ.copy()
    env.update(
        {
            "NO_COLOR": "1",
            "NPM_CONFIG_LOGLEVEL": "silent",
            "npm_config_loglevel": "silent",
            "NPM_CONFIG_FUND": "false",
            "NPM_CONFIG_AUDIT": "false",
            "NO_UPDATE_NOTIFIER": "1",
            "ADBLOCK": "1",
        }
    )

    code, out, err = run_with_timeout([str(wrapper_path)], wrapper_path.parent, env, timeout)

    # Validate stdout lines and detect any JSON-RPC-like output
    bad_lines = []
    saw_protocol = False
    header_re = re.compile(r"^\s*Content-(Length|Type):", re.I)
    obj_re = re.compile(r"^\s*\{")
    arr_re = re.compile(r"^\s*\[\s*(\"|\{|\[|[0-9-]|t|f|n|\])")
    for i, line in enumerate(out.splitlines(), 1):
        if header_re.search(line) or obj_re.search(line) or arr_re.search(line):
            saw_protocol = True
        if not looks_allowed(line):
            bad_lines.append((i, line))
            # Only collect first few to keep output readable
            if len(bad_lines) >= 5:
                break

    ok_content = len(bad_lines) == 0

    # Define run success: either the process stays running (timeout) OR we saw protocol output
    if code is None:
        ok_run = True
    else:
        ok_run = saw_protocol

    ok = ok_content and ok_run
    status = "PASS" if ok else "FAIL"

    details = [f"{status}: {wrapper_path}"]
    if code is None:
        details.append(f"  note: process timed out after {timeout:.1f}s (server likely running)")
    else:
        details.append(f"  note: exited code {code}, stdout lines={len(out.splitlines())}, stderr length={len(err)} bytes")
        if not saw_protocol:
            details.append("  reason: no JSON/Content-* output observed before exit (not a running MCP server)")

    if not ok_content:
        details.append("  offending stdout lines:")
        for ln, txt in bad_lines:
            snippet = txt if len(txt) < 200 else txt[:200] + "…"
            details.append(f"    {ln}: {snippet}")

    return ok, "\n".join(details)


def main():
    parser = argparse.ArgumentParser(description="Smoke test MCP wrapper stdout cleanliness")
    parser.add_argument("--timeout", type=float, default=6.0, help="Seconds to let each wrapper run")
    parser.add_argument("--include-bin", action="store_true", help="Also test wrappers in ~/bin")
    parser.add_argument("wrappers", nargs="*", help="Specific wrapper paths to test")
    args = parser.parse_args()

    repo_root = Path(__file__).resolve().parents[1]

    candidates = [repo_root / p for p in DEFAULT_WRAPPERS]
    if args.include_bin:
        candidates += [Path(p) for p in BIN_WRAPPERS]

    if args.wrappers:
        candidates = [Path(p) for p in args.wrappers]

    any_fail = False
    reports: list[str] = []

    for wp in candidates:
        ok, msg = smoke_one(wp, args.timeout)
        reports.append(msg)
        if not ok:
            any_fail = True

    print("\n".join(reports))
    sys.exit(1 if any_fail else 0)


if __name__ == "__main__":
    main()
