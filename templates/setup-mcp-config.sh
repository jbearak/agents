#!/bin/bash

# Generate MCP configuration with resolved home directory paths
cat > mcp_mac.json << EOF
{
  "servers": {
    "Atlassian": {
      "command": "$HOME/bin/mcp-atlassian-wrapper.sh",
      "args": [],
      "working_directory": null
    },
    "Bitbucket": {
      "command": "$HOME/bin/mcp-bitbucket-wrapper.sh",
      "args": [],
      "working_directory": null
    },
    "Context7": {
      "command": "$HOME/bin/mcp-context7-wrapper.sh",
      "args": [],
      "working_directory": null
    },
    "GitHub": {
      "command": "$HOME/bin/mcp-github-wrapper.sh",
      "args": [],
      "working_directory": null
    }
  }
}
EOF

echo "Generated mcp_mac.json with resolved paths:"
cat mcp_mac.json
