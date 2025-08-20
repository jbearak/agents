#!/opt/homebrew/bin/bash
GITHUB_TOKEN=$(security find-generic-password -s "GitHub" -a "$USER" -w 2>/dev/null)
if [ -z "$GITHUB_TOKEN" ]; then
    echo "Error: Could not retrieve GitHub token from keychain" >&2
    echo "Ensure keychain item 'GitHub' exists and keychain is unlocked" >&2
    exit 1
fi
exec /opt/homebrew/bin/docker run -i --rm \
    -e "GITHUB_PERSONAL_ACCESS_TOKEN=${GITHUB_TOKEN}" \
    ghcr.io/github/github-mcp-server "$@"
