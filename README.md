# Modes & Tools Reference

Centralized documentation for Copilot modes, tool availability, and cross-tool custom instruction usage.

## Table of Contents

- [Repository Structure](#repository-structure)
- [Modes](#modes)
  - [Modes Overview](#modes-overview)
  - [Add Modes to VS Code](#add-modes-to-vs-code)
- [Models](#models)
  - [Models Available in Each Agent](#models-available-in-each-agent)
  - [Simulated Reasoning](#simulated-reasoning)
  - [Context Window](#context-window)
- [MCP Servers](#mcp-servers)
  - [Add MCP Servers to VS Code](#add-mcp-servers-to-vs-code)
  - [Add MCP Servers to Claude.ai](#add-mcp-servers-to-claudeai)
  - [Add MCP Servers to Claude Desktop](#add-mcp-servers-to-claude-desktop)
  - [Tool Availability Matrix](#tool-availability-matrix)
- [Using `code_style_guidelines.txt` Across Tools](#using-code_style_guidelinestxt-across-tools)
  - [GitHub Copilot (Repository-Level)](#github-copilot-repository-level)
  - [GitHub Copilot (GitHub.com Chats)](#github-copilot-githubcom-chats)
  - [Warp (Repository-Level)](#warp-repository-level)
  - [Warp (User-Level)](#warp-user-level)
  - [Q (Repository-Level)](#q-repository-level)
  - [Claude Code (Repository-Level)](#claude-code-repository-level)
- [Tool Definitions](#tool-definitions)
  - [Built-In (VS Code / Core)](#built-in-vs-code--core)
  - [GitHub Pull Requests Extension (VS Code)](#github-pull-requests-extension-vs-code)
  - [Context7](#context7)
  - [Atlassian](#atlassian)
  - [GitHub](#github)
  - [Notes](#notes)

## Repository Structure

```
./
├── code_style_guidelines.txt   # General coding style guidelines
├── README.md                   # This document
└── copilot/
    └── modes/
        ├── QnA.chatmode.md          # Strict read-only Q&A / analysis (no mutations)
        ├── Plan.chatmode.md         # Remote planning & artifact curation + PR create/edit/review (no merge/branch)
        ├── Code-GPT5.chatmode.md    # Full coding, execution, PR + branch ops (GPT-5 model)
        └── Code-Sonnet4.chatmode.md # Full coding, execution, PR + branch ops (Claude Sonnet 4 model)
        ├── Review.chatmode.md       # PR & issue review feedback (comments only)
```

## Modes

### Modes Overview

We define **four categories** of modes for different use cases, that follow a **privilege gradient:** **QnA < Review** (adds review + issue comments) **< Plan** (adds planning artifact + PR creation/edit) **< Code** (full lifecycle incl. merge & branch ops).

From these four categories, we create **five modes**. **Code-GPT5** and **Code-Sonnet4** modes provide the same toolsets with different prompts. We do this because these models respond differently to prompts and possess different strengths. For reference, see OpenAI's [GPT-5 prompting guide](https://cookbook.openai.com/examples/gpt-5/gpt-5_prompting_guide) and Anthropic's [Claude 4 prompt engineering best practices](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/claude-4-best-practices).

<table>
  <thead>
    <tr>
      <th>Mode</th>
      <th>Default Model</th>
      <th>Purpose</th>
      <th>Local File / Repo Mutation</th>
      <th>Remote Artifact Mutation (Issues/Pages/Comments)</th>
      <th>Issue Commenting</th>
      <th>PR Create/Edit</th>
      <th>PR Review (comments / batch)</th>
      <th>PR Merge / Branch Ops</th>
      <th>File</th>
      <th>Contract Summary</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>QnA</td>
      <td>GPT-4.1</td>
      <td>Q&amp;A, exploration, explain code, gather context</td>
      <td>No</td>
      <td>No (read-only viewing only)</td>
      <td>No</td>
      <td>No</td>
      <td>No</td>
      <td>No</td>
      <td><code>copilot/modes/QnA.chatmode.md</code></td>
      <td>Strict read-only (no mutations anywhere)</td>
    </tr>
    <tr>
      <td>Plan</td>
      <td>Sonnet 4</td>
      <td>Plan work, refine scope, shape tickets/pages, organize PR scaffolding</td>
      <td>No</td>
      <td>Yes (issues/pages)</td>
      <td>Yes</td>
      <td>Yes (no branch create/update)</td>
      <td>Yes</td>
      <td>No</td>
      <td><code>copilot/modes/Plan.chatmode.md</code></td>
      <td>Mutate planning artifacts + create/edit/review PRs (no merge/branch ops)</td>
    </tr>
    <tr>
      <td>Review</td>
      <td>GPT-5</td>
      <td>Provide review feedback on PRs / issues</td>
      <td>No</td>
      <td>No (except issue comments)</td>
      <td>Yes (issue comments only)</td>
      <td>No</td>
      <td>Yes</td>
      <td>No</td>
      <td><code>copilot/modes/Review.chatmode.md</code></td>
      <td>PR review + issue comments only; no other mutations</td>
    </tr>
    <tr>
      <td>Code-GPT5</td>
      <td>GPT-5</td>
      <td rowspan="2">Implement changes, run tests/commands</td>
      <td rowspan="2">Yes</td>
      <td rowspan="2">Yes</td>
      <td rowspan="2">Yes</td>
      <td rowspan="2">Yes</td>
      <td rowspan="2">Yes</td>
      <td rowspan="2">Yes</td>
      <td><code>copilot/modes/Code-GPT5.chatmode.md</code></td>
      <td rowspan="2">Full implementation, execution, &amp; PR lifecycle</td>
    </tr>
    <tr>
      <td>Code-Sonnet4</td>
      <td>Sonnet 4</td>
      <td><code>copilot/modes/Code-Sonnet4.chatmode.md</code></td>
    </tr>
  </tbody>
</table>

### Why custom modes?

- In VS Code, **switching among built-in modes does not set the model**.
  - I found this cumbersome, annoying, and a cognitive burden.
  - I wanted to switch between Ask/GPT-4.1 and Agent/Sonnet in one click.
- The built-in **Agent mode does not remember which tools you turned on and off.**
  - When you reopen VS Code, it resets all tools to their default state.
  - This drove me to create custom modes, and then I got carried away...
- You can **type less** because each mode contains prompts tailored to its specific use case.
- The modes contain prompts tailored to their default models.
- **You can still use the built-in modes.**
  - Switch to **Agent** mode when you do not want to use tailored instructions.


### Add Modes to VS Code

1. Choose **Configure Modes...** from the Mode menu in the Chat pane
2. From the "Select the chat mode file to open" menu, press **Create new custom mode chat file...**
3. From the "Select a location to create the mode file in..." menu, press **User Data Folder**
4. From the "Enter the name of the custom chat mode file..." menu, type the mode name as you want it to appear in your modes menu
5. Paste the file

Repeat these steps for:
- [QnA](copilot/modes/QnA.chatmode.md)
- [Plan](copilot/modes/Plan.chatmode.md)
- [Code-Sonnet4](copilot/modes/Code-Sonnet4.chatmode.md)
- [Code-GPT5](copilot/modes/Code-GPT5.chatmode.md)
- [Review](copilot/modes/Review.chatmode.md)


You can also download the files directly to the folder:
- Windows: C:\Users\<username>\AppData\Roaming\Code\User\prompts\
- Mac: ~/Library/Application Support/Code/User/prompts/

On Mac you can use emojis in the file names:
  - 📚 QnA
  - 🔭 Plan
  - 🚀 Code-GPT5
  - ☄️ Code-Sonnet4
  - 🔬 Review

## Models

### Models Available in Each Agent

| Agent             | Sonnet 4 | Opus 4.1 | GPT-5 | GPT-5 mini | GPT 4.1 | Gemini 2.5 Pro | Gemini 2.5 Flash |
|-------------------|----------|----------|-------|------------|---------|----------------|------------------|
| Claude.ai/Desktop | ✅      | ✅        | ❌     | ❌         | ❌      | ❌              | ❌              |
| Claude Code       | ✅      | ✅        | ❌     | ❌         | ❌      | ❌              | ❌              |
| GitHub Copilot    | ✅      | ❌        | ✅     | ✅         | ✅      | ✅              | ❌              |
| Q                 | ✅      | ❌        | ❌     | ❌         | ❌      | ❌              | ❌              |
| Rovo              | ✅      | ❌        | ✅     | ❌         | ❌      | ❌              | ❌              |
| Warp              | ✅      | ✅        | ✅     | ❌         | ✅      | ✅              | ✅              |

**Note:** None of these agents specify whether GPT-5 refers to the model with minimal, low, medium, or high reasoning.


### Simulated Reasoning

| Agent             | SR Available | Notes |
|-------------------|--------------|-----------------------------------------------------------|
| Claude.ai/Desktop | ✅           | Toggle "Extended thinking" in the "Search and tools" menu |
| Claude Code       | ✅           | Use keywords: ["think" < "think hard" < "think harder" < "ultrathink"](https://www.anthropic.com/engineering/claude-code-best-practices)       |
| GitHub Copilot    | —            | Use Sonnet 3.7                                            |
| Q                 | —            |                                                           |
| Rovo              | —            |                                                           |
| Warp              | —            | Use o3                                                    |


### Context Window

| Agent             | Claude Sonnet and Opus | GPT-5 and GPT-5 mini | GPT 4.1 | Gemini  |
|-------------------|------------------------|----------------------|---------|---------|
| GitHub Copilot    | 111,836                | 108,637              | 111,452	| 108,637 |
| Claude.ai/Desktop | 200,000                | —                    | —       | —       |
| Claude Code       | 200,000                | —                    | —       | —       |
| Rovo              | 200,000                | 400,000              |         | —       |
| Q                 | 200,000                | —                    |         | —       |
| Warp              | 200,000                | ?                    | ?       | ?       |

- Context windows are measured in tokens.
- A token is roughly 4 characters long.
- For example, 'unbreakable' consists of 'un' - 'break' - 'able'.

**Note:** Agents will generally compress/prune context windows to fit within their limits in multi-turn chats. However, Claude.ai/Desktop will not; if after several turns you exceed the context window, you cannot continue the chat.

## MCP Servers

### Add MCP Servers to VS Code

Microsoft maintains a list, [MCP Servers for agent mode](https://code.visualstudio.com/mcp). From this list, press:
- [Install GitHub](vscode:mcp/install?%7B%22name%22%3A%22github%22%2C%22gallery%22%3Atrue%2C%22url%22%3A%22https%3A%2F%2Fapi.githubcopilot.com%2Fmcp%2F%22%7D)
- [Install Atlassian](vscode:mcp/install?%7B%22name%22%3A%22atlassian%22%2C%22gallery%22%3Atrue%2C%22url%22%3A%22https%3A%2F%2Fmcp.atlassian.com%2Fv1%2Fsse%22%7D)
- [Install Context7](vscode:mcp/install?%7B%22name%22%3A%22context7%22%2C%22gallery%22%3Atrue%2C%22command%22%3A%22npx%22%2C%22args%22%3A%5B%22-y%22%2C%22%40upstash%2Fcontext7-mcp%40latest%22%5D%7D)

Each of these links opens a VS Code window. For each of these MCP servers, press the **Install** button in that window. For Atlassian and GitHub, follow the steps to authorize Copilot to connect with them.

If you prefer to install the MCP servers manually:

1. From the Command Palette, choose **MCP: Open User Configuration**
2. Paste:

```json
{
  "servers": {
    "atlassian": {
      "url": "https://mcp.atlassian.com/v1/sse",
      "type": "http"
    },
    "github": {
      "url": "https://api.githubcopilot.com/mcp/",
      "type": "http"
    },
    "context7": {
      "command": "npx",
      "args": [
        "-y",
        "@upstash/context7-mcp@latest"]
    }
  }
}
```

### Add MCP Servers to Claude.ai

1. Open [Settings > Connectors](https://claude.ai/settings/connectors)
2. Press each the **Connect** button (next to Atlassian and GitHub)
Note: This adds the ability to add files from GitHub, but does not add the [GitHub MCP Server](https://github.com/github/github-mcp-server/blob/main/docs/installation-guides/install-claude.md).

### Add MCP Servers to Claude Desktop

When you connect MCP servers in Claude.ai, they automatically become available in Claude Desktop. Therefore, only add local servers.

1. Open Settings > Developer > Edit Config
2. Open `claude_desktop_config.json` for editing
3. Paste:
```
{
    "mcpServers": {
        "Context7": {
            "command": "npx",
            "args": [
                "-y",
                "@upstash/context7-mcp"
            ],
            "env": {},
            "working_directory": null
        },
        "GitHub": {
            "command": "docker",
            "args": [
                "run",
                "-i",
                "--rm",
                "-e",
                "GITHUB_PERSONAL_ACCESS_TOKEN",
                "ghcr.io/github/github-mcp-server"
            ],
            "env": {
                "GITHUB_PERSONAL_ACCESS_TOKEN": "<Your_GitHub_Token_Here>"
            }
        }
    }
}
```
4. Obtain your GitHub personal access token from [GitHub Settings](https://github.com/settings/tokens) and paste it in place of `<Your_GitHub_Token_Here>`
5. Restart Claude Desktop

#### Storing GitHub Token in Keychain

You can store your GitHub personal access token in your login keychain instead of pasting it directly into the config file. To do this on a Mac:

Your `claude_desktop_config.json` file should look like this:

```json
{
    "mcpServers": {
        "Context7": {
            "command": "npx",
            "args": [
                "-y",
                "@upstash/context7-mcp"
            ],
            "env": {},
            "working_directory": null
        },
        "GitHub": {
            "command": "/Users/<username>/bin/mcp-github-wrapper.sh",
            "args": [],
            "env": {
            "DOCKER_HOST": "unix:///Users/<username>/.colima/default/docker.sock"
            },
            "working_directory": null
        }
    }
}
```

0. Replace `<username>` with your actual username in the config file.
1. Open Keychain Access and create a new generic password named GitHub which contains your access token.
2. Create a file named `~/bin/mcp-github-wrapper.sh` with the following content:

```bash
#!/opt/homebrew/bin/bash
GITHUB_TOKEN=$(security find-generic-password -s "GitHub" -a "$USER" -w 2>/dev/null)

# Check if token was retrieved successfully
if [ -z "$GITHUB_TOKEN" ]; then
    echo "Error: Could not retrieve GitHub token from keychain" >&2
    echo "Make sure the token is stored in keychain with service name 'GitHub'" >&2
    echo "You may need to run: security unlock-keychain" >&2
    exit 1
fi

# Run the Docker container with the token
exec /opt/homebrew/bin/docker run -i --rm \
    -e "GITHUB_PERSONAL_ACCESS_TOKEN=${GITHUB_TOKEN}" \
    ghcr.io/github/github-mcp-server "$@"

```


### Tool Availability Matrix

- Modes organized left-to-right from least to most privileges
- Review mode adds PR review + issue commenting over QnA, without broader planning artifact mutation.
- Plan mode extends Review with planning artifact creation/edit and PR creation/edit (no merge / branch ops).
- Code modes include full repository mutation (branches, merges, execution).
- See [Modes](#modes)

Note: "Code" shows toolsets for "Code - GPT-5" and "Code - Sonnet-4" modes.

Legend: ✅ available, ❌ unavailable in that mode.

| Tool | QnA | Review | Plan | Code |
|------|-----|--------|------|------|
| **Built-In (VS Code / Core)** | | | | |
| *Code & Project Navigation* | | | | |
| [codebase](#codebase) | ✅ | ✅ | ✅ | ✅ |
| [findTestFiles](#findtestfiles) | ✅ | ✅ | ✅ | ✅ |
| [search](#search) | ✅ | ✅ | ✅ | ✅ |
| [searchResults](#searchresults) | ✅ | ✅ | ✅ | ✅ |
| [usages](#usages) | ✅ | ✅ | ✅ | ✅ |
| *Quality & Diagnostics* | | | | |
| [problems](#problems) | ✅ | ✅ | ✅ | ✅ |
| [testFailure](#testfailure) | ✅ | ✅ | ✅ | ✅ |
| *Version Control & Changes* | | | | |
| [changes](#changes) | ✅ | ✅ | ✅ | ✅ |
| *Environment & Execution* | | | | |
| [terminalLastCommand](#terminallastcommand) | ✅ | ✅ | ✅ | ✅ |
| [terminalSelection](#terminalselection) | ❌ | ❌ | ❌ | ✅ |
| *Web & External Content* | | | | |
| [fetch](#fetch) | ✅ | ✅ | ✅ | ✅ |
| [githubRepo](#githubrepo) | ✅ | ✅ | ✅ | ✅ |
| *Editor & Extensions* | | | | |
| [extensions](#extensions) | ❌ | ❌ | ❌ | ❌ |
| [vscodeAPI](#vscodeapi) | ❌ | ❌ | ❌ | ❌ |
| *Editing & Automation* | | | | |
| [editFiles](#editfiles) | ❌ | ❌ | ❌ | ✅ |
| [runCommands](#runcommands) | ❌ | ❌ | ❌ | ✅ |
| [runTasks](#runtasks) | ❌ | ❌ | ❌ | ✅ |
| **GitHub Pull Requests Extension (VS Code)** | | | | |
| [activePullRequest](#activepullrequest) | ✅ | ✅ | ✅ | ✅ |
| [copilotCodingAgent](#copilotcodingagent) | ❌ | ❌ | ❌ | ✅ |
| **Context7** | | | | |
| [resolve-library-id](#resolve-library-id) | ✅ | ✅ | ✅ | ✅ |
| [get-library-docs](#get-library-docs) | ✅ | ✅ | ✅ | ✅ |
| **Atlassian** | | | | |
| *Jira Issues & Operations* | | | | |
| [addCommentToJiraIssue](#addcommenttojiraissue) | ❌ | ✅ | ✅ | ✅ |
| [createJiraIssue](#createjiraissue) | ❌ | ❌ | ✅ | ✅ |
| [editJiraIssue](#editjiraissue) | ❌ | ❌ | ✅ | ✅ |
| [getJiraIssue](#getjiraissue) | ✅ | ✅ | ✅ | ✅ |
| [getJiraIssueRemoteIssueLinks](#getjiraissueremoteissuelinks) | ✅ | ✅ | ✅ | ✅ |
| [getTransitionsForJiraIssue](#gettransitionsforjiraissue) | ❌ | ❌ | ❌ | ❌ |
| [searchJiraIssuesUsingJql](#searchjiraissuesusingjql) | ✅ | ✅ | ✅ | ✅ |
| [transitionJiraIssue](#transitionjiraissue) | ❌ | ❌ | ✅ | ✅ |
| *Jira Project Metadata* | | | | |
| [getJiraProjectIssueTypesMetadata](#getjiraprojectissuetypesmetadata) | ✅ | ✅ | ✅ | ✅ |
| [getVisibleJiraProjects](#getvisiblejiraprojects) | ✅ | ✅ | ✅ | ✅ |
| *Confluence Pages & Content* | | | | |
| [createConfluencePage](#createconfluencepage) | ❌ | ❌ | ✅ | ✅ |
| [getConfluencePage](#getConfluencePage) | ✅ | ✅ | ✅ | ✅ |
| [getConfluencePageAncestors](#getConfluencePageAncestors) | ❌ | ❌ | ❌ | ❌ |
| [getConfluencePageDescendants](#getConfluencePageDescendants) | ❌ | ❌ | ❌ | ❌ |
| [getPagesInConfluenceSpace](#getPagesInConfluenceSpace) | ✅ | ✅ | ✅ | ✅ |
| [updateConfluencePage](#updateConfluencePage) | ❌ | ❌ | ✅ | ✅ |
| *Confluence Comments* | | | | |
| [createConfluenceFooterComment](#createConfluenceFooterComment) | ❌ | ❌ | ✅ | ✅ |
| [createConfluenceInlineComment](#createConfluenceInlineComment) | ❌ | ❌ | ✅ | ✅ |
| [getConfluencePageFooterComments](#getConfluencePageFooterComments) | ✅ | ✅ | ✅ | ✅ |
| [getConfluencePageInlineComments](#getConfluencePageInlineComments) | ✅ | ✅ | ✅ | ✅ |
| *Confluence Spaces & Discovery* | | | | |
| [getConfluenceSpaces](#getConfluenceSpaces) | ✅ | ✅ | ✅ | ✅ |
| [searchConfluenceUsingCql](#searchConfluenceUsingCql) | ✅ | ✅ | ✅ | ✅ |
| *User & Identity* | | | | |
| [atlassianUserInfo](#atlassianuserinfo) | ✅ | ✅ | ✅ | ✅ |
| [lookupJiraAccountId](#lookupjiraaccountid) | ✅ | ✅ | ✅ | ✅ |
| *Other* | | | | |
| [getAccessibleAtlassianResources](#getaccessibleatlassianresources) | ✅ | ✅ | ✅ | ✅ |
| **GitHub** | | | | |
| *Commits & Repository* | | | | |
| [create_branch](#create_branch) | ❌ | ❌ | ❌ | ✅ |
| [create_repository](#create_repository) | ❌ | ❌ | ❌ | ✅ |
| [get_commit](#get_commit) | ✅ | ✅ | ✅ | ✅ |
| [get_file_contents](#get_file_contents) | ✅ | ✅ | ✅ | ✅ |
| [get_tag](#get_tag) | ❌ | ❌ | ❌ | ❌ |
| [list_branches](#list_branches) | ✅ | ✅ | ✅ | ✅ |
| [list_commits](#list_commits) | ✅ | ✅ | ✅ | ✅ |
| [list_tags](#list_tags) | ❌ | ❌ | ❌ | ❌ |
| [push_files](#push_files) | ❌ | ❌ | ❌ | ✅ |
| *Pull Requests  Retrieval* | | | | |
| [get_pull_request](#get_pull_request) | ✅ | ✅ | ✅ | ✅ |
| [get_pull_request_comments](#get_pull_request_comments) | ✅ | ✅ | ✅ | ✅ |
| [get_pull_request_diff](#get_pull_request_diff) | ✅ | ✅ | ✅ | ✅ |
| [get_pull_request_files](#get_pull_request_files) | ✅ | ✅ | ✅ | ✅ |
| [get_pull_request_reviews](#get_pull_request_reviews) | ✅ | ✅ | ✅ | ✅ |
| [get_pull_request_status](#get_pull_request_status) | ✅ | ✅ | ✅ | ✅ |
| [list_pull_requests](#list_pull_requests) | ✅ | ✅ | ✅ | ✅ |
| *Pull Requests  Actions* | | | | |
| [add_comment_to_pending_review](#add_comment_to_pending_review) | ❌ | ✅ | ✅ | ✅ |
| [create_pending_pull_request_review](#create_pending_pull_request_review) | ❌ | ✅ | ✅ | ✅ |
| [create_pull_request](#create_pull_request) | ❌ | ❌ | ✅ | ✅ |
| [create_pull_request_with_copilot](#create_pull_request_with_copilot) | ❌ | ❌ | ❌ | ✅ |
| [merge_pull_request](#merge_pull_request) | ❌ | ❌ | ❌ | ✅ |
| [request_copilot_review](#request_copilot_review) | ❌ | ❌ | ❌ | ❌ |
| [submit_pending_pull_request_review](#submit_pending_pull_request_review) | ❌ | ✅ | ✅ | ✅ |
| [update_pull_request](#update_pull_request) | ❌ | ❌ | ✅ | ✅ |
| [update_pull_request_branch](#update_pull_request_branch) | ❌ | ❌ | ❌ | ✅ |
| *Sub-Issues* | | | | |
| [list_sub_issues](#list_sub_issues) | ✅ | ✅ | ✅ | ✅ |
| [reprioritize_sub_issue](#reprioritize_sub_issue) | ❌ | ❌ | ✅ | ❌ |
| *Gists* | | | | |
| [list_gists](#list_gists) | ❌ | ❌ | ❌ | ❌ |
| [update_gist](#update_gist) | ❌ | ❌ | ❌ | ❌ |
| *Notifications* | | | | |
| [list_notifications](#list_notifications) | ✅ | ✅ | ✅ | ✅ |
| *Code Scanning & Security* | | | | |
| [list_code_scanning_alerts](#list_code_scanning_alerts) | ❌ | ❌ | ❌ | ❌ |
| *Workflows (GitHub Actions)* | | | | |
| [get_workflow_run](#get_workflow_run) | ✅ | ❌ | ✅ | ✅ |
| [get_workflow_run_logs](#get_workflow_run_logs) | ❌ | ❌ | ❌ | ❌ |
| [get_workflow_run_usage](#get_workflow_run_usage) | ❌ | ❌ | ❌ | ❌ |
| [list_workflow_jobs](#list_workflow_jobs) | ❌ | ❌ | ❌ | ❌ |
| [list_workflow_run_artifacts](#list_workflow_run_artifacts) | ✅ | ❌ | ✅ | ✅ |
| [list_workflow_runs](#list_workflow_runs) | ❌ | ❌ | ❌ | ❌ |
| [list_workflows](#list_workflows) | ❌ | ❌ | ❌ | ❌ |
| [rerun_failed_jobs](#rerun_failed_jobs) | ❌ | ❌ | ❌ | ❌ |
| [rerun_workflow_run](#rerun_workflow_run) | ❌ | ❌ | ❌ | ❌ |
| *Search & Discovery* | | | | |
| [search_code](#search_code) | ✅ | ✅ | ✅ | ✅ |
| [search_orgs](#search_orgs) | ❌ | ❌ | ❌ | ❌ |
| [search_pull_requests](#search_pull_requests) | ✅ | ✅ | ✅ | ✅ |
| [search_repositories](#search_repositories) | ✅ | ✅ | ✅ | ✅ |
| [search_users](#search_users) | ❌ | ❌ | ❌ | ❌ |
| *User & Account* | | | | |
| [get_me](#get_me) | ✅ | ✅ | ✅ | ✅ |
| *File Operations* | | | | |
| [create_or_update_file](#create_or_update_file) | ❌ | ❌ | ❌ | ✅ |

## Using `code_style_guidelines.txt` Across Tools

### GitHub Copilot (Repository-Level)
1. Create or edit `.github/copilot-instructions.md`
2. Paste `code_style_guidelines.txt` content.

Reference: [Adding repository custom instructions for GitHub Copilot](https://docs.github.com/en/enterprise-cloud@latest/copilot/how-tos/configure-custom-instructions/add-repository-instructions)

### GitHub Copilot (GitHub.com Chats)

#### Organization-Level Instructions
**Note:** Organization custom instructions are currently only supported for GitHub Copilot Chat in GitHub.com and do not affect VS Code or other editors. For editor support, see [GitHub Copilot (Repository-Level)](#github-copilot-repository-level) below.

1. Org admin navigates to GitHub: Settings > (Organization) > Copilot > Policies / Custom Instructions.
2. Open Custom Instructions editor and paste the full contents of `code_style_guidelines.txt`.
3. Save; changes propagate to organization members (may require editor reload).
4. Version control: treat this repository file as the single source of truth; update here first, then re-paste.

Reference: [Adding organization custom instructions for GitHub Copilot](https://docs.github.com/en/enterprise-cloud@latest/copilot/how-tos/configure-custom-instructions/add-organization-instructions)

#### Personal Instructions
**Note:** Personal custom instructions are currently only supported for GitHub Copilot Chat in GitHub.com and do not affect VS Code or other editors.

Since the organization-level instructions equal `code_style_guidelines.txt`, do not re-paste it here. However, you may wish to customize Copilot Chat behavior further.

1. Navigate to GitHub: Settings > (Personal) > Copilot > Custom Instructions.
2. Open Custom Instructions editor and paste your personal instructions.
3. Save; changes apply to your personal GitHub.com chats.

Reference: [Adding personal custom instructions for GitHub Copilot](https://docs.github.com/en/copilot/how-tos/configure-custom-instructions/add-personal-instructions)

### Warp (Repository-Level)
1. Create `WARP.md`
2. Paste [code_style_guidelines.txt](code_style_guidelines.txt) content.
3. Save the file.

### Warp (User-Level)
1. Open `Warp Drive` (the left sidebar) > `Rules` > `+ Add`
2. Paste your personal instructions.
3. Save the new rule.


### Q (Repository-Level)
1. Create `.amazonq/rules/code_style_guidelines.txt` in the repository root
2. Paste [code_style_guidelines.txt](code_style_guidelines.txt) content.
3. Save the file.

### Claude Code (Repository-Level)
1. Create or edit `CLAUDE.md` in the repository root
2. Paste [code_style_guidelines.txt](code_style_guidelines.txt) content.
3. Save the file.

## Tool Definitions

### Built-In (VS Code / Core)

#### Code & Project Navigation

##### codebase
Search, read, and analyze project source code.
##### findTestFiles
Given a source (or test) file, locate its corresponding test (or source) counterpart.
##### search
Search and read files in the workspace.
##### searchResults
Access the current search view results programmatically.
##### usages
Find references, definitions, implementations, and other symbol usages.
#### Quality & Diagnostics
##### problems
Retrieve diagnostics (errors/warnings) for a file.
##### testFailure
Surface details about the most recent unit test failure.
#### Version Control & Changes
##### changes
Get diffs of locally changed files.
#### Environment & Execution
##### terminalLastCommand
Return the last executed command in the active terminal.
##### terminalSelection
Return the currently selected text in the terminal (Code mode only).
#### Web & External Content
##### fetch
Fetch main textual content from a web page (provide URL and optional query focus).
##### githubRepo
Search a public GitHub repository for relevant code snippets.
#### Editor & Extensions
##### extensions
Discover or inspect installed/available editor extensions.
##### vscodeAPI
Query VS Code API references and docs (Code mode only).
#### Editing & Automation
##### editFiles
Edit existing workspace files (Code mode only; mutating).
##### runCommands
Execute arbitrary shell/CLI commands in a persistent terminal (Code mode only).
##### runTasks
Create/run tasks (build/test/etc.) via tasks configuration (Code mode only).

### GitHub Pull Requests Extension (VS Code)
#### activePullRequest
Retrieve context for the currently focused pull request.
#### copilotCodingAgent
Completes the provided task using an asynchronous coding agent. Use when the user wants copilot to continue completing a task in the background or asynchronously. Launch an autonomous GitHub Copilot agent to work on coding tasks in the background. The agent will create a new branch, implement the requested changes, and open a pull request with the completed work. 

### Context7

The [Context7 MCP Server](https://github.com/upstash/context7) retrieves up-to-date documentation and code examples for various programming languages and frameworks, from community-contributed sources (e.g., [ggplot2](https://context7.com/tidyverse/ggplot2)).

#### resolve-library-id
Resolve a package/library name to a Context7-compatible identifier.

#### get-library-docs
Retrieve up-to-date documentation snippets for a resolved library ID.

### Atlassian

The [Atlassian Remote MCP Server](https://support.atlassian.com/rovo/docs/getting-started-with-the-atlassian-remote-mcp-server/) provides lets an agent read/write from/to Jira and Confluence (but not Bitbucket).

#### Jira Issues & Operations
##### addCommentToJiraIssue
Add a comment to a Jira issue.
##### createJiraIssue
Create a new Jira issue in a project.
##### editJiraIssue
Update fields of an existing Jira issue.
##### getJiraIssue
Fetch details for a Jira issue by key or ID.
##### getJiraIssueRemoteIssueLinks
Retrieve remote issue links (e.g., Confluence pages) tied to a Jira issue.
##### getTransitionsForJiraIssue
List available transitions for a Jira issue.
##### searchJiraIssuesUsingJql
Search Jira issues with JQL.
##### transitionJiraIssue
Move an issue through a workflow transition.
#### Jira Project Metadata
##### getJiraProjectIssueTypesMetadata
Metadata/details for issue types in a Jira project.
##### getVisibleJiraProjects
List Jira projects visible to the user (permission-filtered).
#### Confluence Pages & Content
##### createConfluencePage
Create a Confluence page (regular or live doc).
##### getConfluencePage
Fetch a Confluence page (body converted to Markdown).
##### getConfluencePageAncestors
List ancestor hierarchy for a page.
##### getConfluencePageDescendants
List descendant pages (optionally depth-limited).
##### getPagesInConfluenceSpace
List pages within a Confluence space.
##### updateConfluencePage
Update an existing Confluence page or live doc.
#### Confluence Comments
##### createConfluenceFooterComment
Add a footer comment to a page/blog post.
##### createConfluenceInlineComment
Add an inline (text-anchored) comment to a page.
##### getConfluencePageFooterComments
List footer comments for a page.
##### getConfluencePageInlineComments
List inline comments for a page.
#### Confluence Spaces & Discovery
##### getConfluenceSpaces
List spaces and related metadata.
##### searchConfluenceUsingCql
Query Confluence content using CQL.
#### User & Identity
##### atlassianUserInfo
Get current Atlassian user identity info.
##### lookupJiraAccountId
Lookup account IDs by user name/email.
#### Other
##### getAccessibleAtlassianResources
Discover accessible Atlassian cloud resources and obtain cloud IDs.

### GitHub

The [GitHub MCP Server](https://github.com/github/github-mcp-server) lets an agent read/write from/to GitHub.

#### Commits & Repository
##### create_branch
Create a branch from a base ref (Code mode only).
##### create_repository
Create a new repository (mutation; Code mode only).
##### get_commit
Get details for a specific commit.
##### get_file_contents
Retrieve file or directory listing content from a repo.
##### get_tag
Get details for a tag.
##### list_branches
List branches in a repository.
##### list_commits
List commits on a branch or up to a commit SHA.
##### list_tags
List tags in a repository.
##### push_files
Push multiple files in a single commit (Code mode only).
#### Pull Requests – Retrieval
##### activePullRequest
Retrieve context for the currently focused pull request.
##### get_pull_request
Retrieve pull request details.
##### get_pull_request_comments
List comments on a pull request.
##### get_pull_request_diff
Retrieve a diff for a pull request.
##### get_pull_request_files
List changed files in a pull request.
##### get_pull_request_reviews
List reviews on a pull request.
##### get_pull_request_status
Fetch status checks for a pull request.
##### list_pull_requests
List pull requests with filters.
#### Pull Requests – Actions
##### add_comment_to_pending_review
Add a comment to an in-progress pending review (Code mode only).
##### create_pending_pull_request_review
Start a pending review (Code mode only).
##### create_pull_request
Open a new pull request (Code mode only).
##### create_pull_request_with_copilot
Delegate implementation task leading to a new PR (Code mode only).
##### merge_pull_request
Merge a pull request (Code mode only).
##### request_copilot_review
Request automated Copilot code review for a PR (Code mode only).
##### submit_pending_pull_request_review
Submit a pending review (Code mode only).
##### update_pull_request
Modify title/body/draft state of a pull request (Code mode only).
##### update_pull_request_branch
Update PR branch with base (Code mode only).

#### Sub-Issues
##### list_sub_issues
List sub-issues for a GitHub issue (Beta feature).
##### reprioritize_sub_issue
Reorder sub-issue priority (Code mode only).
#### Gists
##### list_gists
List gists for a user.
##### update_gist
Update an existing gist (Code mode only).
#### Notifications
##### list_notifications
List all notifications (filters optional).
#### Code Scanning & Security
##### list_code_scanning_alerts
List code scanning alerts.
#### Workflows (GitHub Actions)
##### get_workflow_run
Get details for a workflow run.
##### get_workflow_run_logs
Download logs (ZIP) for a workflow run.
##### get_workflow_run_usage
Get billable time/usage metrics for a run.
##### list_workflow_jobs
List jobs for a workflow run.
##### list_workflow_run_artifacts
List artifacts produced by a workflow run.
##### list_workflow_runs
List workflow runs with filtering options.
##### list_workflows
List workflows configured in a repository.
##### rerun_failed_jobs
Re-run only failed jobs in a run (Code mode only).
##### rerun_workflow_run
Re-run an entire workflow run (Code mode only).
#### Search & Discovery
##### search_code
Global code search across GitHub.
##### search_orgs
Search for GitHub organizations.
##### search_pull_requests
Search pull requests across repositories.
##### search_repositories
Search for repositories by criteria.
##### search_users
Search for GitHub users.

#### User & Account
##### get_me
Get details for the authenticated GitHub user.

#### File Operations
##### create_or_update_file
Create or update a single file in a repository (Code mode only).

### Notes
- Definitions come from the MCP servers
- QnA mode excludes all mutating / execution capabilities. Plan mode excludes code / repo / execution capabilities but permits planning artifact mutations. Code mode includes full capabilities.
- This document is the canonical source for tool availability.
- Update the table and definitions together, and test that you made corresponding edits across this file and the chatmode.md files with `Rscript validate_tools.R`
