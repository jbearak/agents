# Claude Instructions for This Repository

These notes help Claude (and you) run and debug local MCP servers consistently.

Key wrappers
- GitHub: ~/bin/mcp-github-wrapper.sh (CLI → npx @latest → Docker)
- Atlassian: ~/bin/mcp-atlassian-wrapper.sh (CLI → npx @latest → Docker)
- Bitbucket: ~/bin/mcp-bitbucket-wrapper.sh (CLI → npx @latest → Docker if configured)

Important: stdout must be JSON-only
- MCP clients parse JSON-RPC on stdout. Any banners or human text on stdout can break initialization.
- Our wrappers send diagnostics to stderr on purpose. Seeing messages labeled as “warnings” in UIs is expected and safe.

Quick smoke test for wrappers
- We provide scripts that verify wrapper stdout is clean (JSON-only) and safe for MCP clients.
- Run from repo root or anywhere:
  - Python: python3 scripts/smoke_mcp_wrappers.py --timeout 6.0
- Options:
  - --include-bin to also test the copies in ~/bin
  - Provide specific paths to test particular wrappers

Examples
- Test installed copies in ~/bin: scripts/smoke_mcp_wrappers.py --include-bin
- Test only the GitHub wrapper: scripts/smoke_mcp_wrappers.py templates/mcp-github-wrapper.sh

Credentials
- GitHub
  - Prefer macOS Keychain item named “GitHub”, or set GITHUB_PERSONAL_ACCESS_TOKEN in the environment used by the editor.
- Atlassian
  - Keychain item: service “atlassian-mcp-local”, account “api-token”, value is your API token.
  - Set ATLASSIAN_DOMAIN and ATLASSIAN_EMAIL in the agent configs.
- Bitbucket
  - Keychain item: service “bitbucket-mcp”, account “app-password”, value is your app password.
  - Set ATLASSIAN_BITBUCKET_USERNAME in the agent configs.

Troubleshooting symptom → action
- “Failed to parse message: '\n'” or similar in clients:
  - The server printed banners on stdout. Use the GitHub Docker image (preferred) or ensure wrappers filter stdout to JSON only.
- Immediate exit before initialize:
  - Missing credentials or docker daemon not running. Check stderr for “Using … via …” line and error details.

Style
- Keep stdout machine-readable. Log to stderr or a file when in doubt.

