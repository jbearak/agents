# Modes & Tools Reference

Reference for Copilot modes, models, MCP servers, and cross-tool custom instruction usage.

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
  - [Hosted MCP Servers (Simple Setup)](#hosted-mcp-servers-simple-setup)
  - [Local MCP Server Configuration](#local-mcp-server-configuration)
  - [Agent Configuration](#agent-configuration)
  - [Tool Availability Matrix](#tool-availability-matrix)
- [Tools Glossary](TOOLS_GLOSSARY.md)
- [Repository Validation](#repository-validation)
- [Using `code_style_guidelines.txt` Across Tools](#using-code_style_guidelinestxt-across-tools)
  - [GitHub Copilot (Repository-Level)](#github-copilot-repository-level)
  - [GitHub Copilot (GitHub.com Chats)](#github-copilot-githubcom-chats)
  - [Warp (Repository-Level)](#warp-repository-level)
  - [Warp (User-Level)](#warp-user-level)
  - [Q (Repository-Level)](#q-repository-level)
  - [Claude Code (Repository-Level)](#claude-code-repository-level)

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

**Note:** One can use any model with any mode. For example, one might use Review mode with Sonnet or Gemini.

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
| Warp              | ✅      | ✅        | ✅     | ❌         | ✅      | ✅              | ✅              |

**Note:** None of these agents specify whether GPT-5 refers to the model with minimal, low, medium, or high reasoning.


### Simulated Reasoning

| Agent             | SR Available | Notes |
|-------------------|--------------|-----------------------------------------------------------|
| Claude.ai/Desktop | ✅           | Toggle "Extended thinking" in the "Search and tools" menu |
| Claude Code       | ✅           | Use keywords: ["think" < "think hard" < "think harder" < "ultrathink"](https://www.anthropic.com/engineering/claude-code-best-practices)       |
| GitHub Copilot    | —            | Has Sonnet 3.7 Thinking and o4 mini                       |
| Q                 | —            |                                                           |
| Warp              | —            | Has o3 and o4 mini                                        |


**Note:** [GPT-5 adds reasoning_effort and verbosity parameters ranging from minimal/low to high](https://openai.com/index/introducing-gpt-5-for-developers/), but providers do not transparently communicate how they configure it. One can access high/high settings for planning tasks via the OpenAI API–agents that one can configure with API keys include [Codex](https://help.openai.com/en/articles/11096431-openai-codex-cli-getting-started) and [Roo](https://github.com/RooCodeInc/Roo-Code). (GitHub does not [yet](https://www.reddit.com/r/GithubCopilot/comments/1leq2q3/bring_your_own_keys_for_business_plan/) support BYOK on Copilot Business, and [seems](https://github.com/microsoft/vscode/issues/260460) to be refactoring their custom providers API.)

### Context Window

| Agent             | Claude Sonnet | GPT-5     | GPT 4.1   | Gemini    |
|-------------------|---------------|-----------|-----------|-----------|
| GitHub Copilot    | 111,836       | 108,637   | 111,452	  | 108,637   |
| Claude.ai/Desktop | 200,000       | —         | —         | —         |
| Claude Code       | 200,000       | —         | —         | —         |
| Q                 | 200,000       | —         |           | —         |
| Warp              | 200,000       | ?         | ?         | ?         |
| **API:**          | 200,000       | 400,000   | 1,000,000 | 1,000,000 |
| (in beta in API)  | (1,000,000)   | —         | —         | —         |

- Context windows are measured in tokens.
- A token is roughly 4 characters long.
- For example, 'unbreakable' consists of 'un' - 'break' - 'able'.

**Note:** Agents will generally compress/prune context windows to fit within their limits in multi-turn chats. However, Claude.ai/Desktop will not; if after several turns you exceed the context window, you cannot continue the chat.


## MCP Servers

### Hosted MCP Servers (Simple Setup)

Microsoft maintains a list, [MCP Servers for agent mode](https://code.visualstudio.com/mcp). These are the easiest to set up as they require no local configuration:

- [Install GitHub](vscode:mcp/install?%7B%22name%22%3A%22github%22%2C%22gallery%22%3Atrue%2C%22url%22%3A%22https%3A%2F%2Fapi.githubcopilot.com%2Fmcp%2F%22%7D)
- [Install Atlassian](vscode:mcp/install?%7B%22name%22%3A%22atlassian%22%2C%22gallery%22%3Atrue%2C%22url%22%3A%22https%3A%2F%2Fmcp.atlassian.com%2Fv1%2Fsse%22%7D)
- [Install Context7](vscode:mcp/install?%7B%22name%22%3A%22context7%22%2C%22gallery%22%3Atrue%2C%22command%22%3A%22npx%22%2C%22args%22%3A%5B%22-y%22%2C%22%40upstash%2Fcontext7-mcp%40latest%22%5D%7D)

Each of these links opens a VS Code window. For each MCP server, press the **Install** button in that window. For Atlassian and GitHub, follow the steps to authorize Copilot to connect with them.

If you prefer to install the hosted MCP servers manually:

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
        "@upstash/context7-mcp@latest"
      ]
    }
  }
}
```

### Local MCP Server Configuration

The following MCP servers require local wrapper scripts for enhanced capabilities and secure credential storage. These provide additional functionality beyond the hosted servers.

#### GitHub MCP Server (Local)

For enhanced GitHub capabilities beyond the hosted version, use the local GitHub MCP server with secure credential management.

**Windows (Credential Manager + PowerShell + Podman)**

1. Store token securely:
   - Control Panel → User Accounts → Credential Manager → Windows Credentials → Add a generic credential.
   - Internet or network address: `GitHub`
   - Username: `token` (placeholder)
   - Password: (your PAT)
2. (Optional) Inspect via PowerShell:
   ```powershell
   Install-Module -Name CredentialManager -Scope CurrentUser -Force
   Import-Module CredentialManager
   Get-StoredCredential -Target GitHub
   ```
3. Use the provided wrapper script: copy [`scripts/mcp-github-wrapper.ps1`](scripts/mcp-github-wrapper.ps1) to `C:\Users\<username>\bin\mcp-github-wrapper.ps1`
4. Ensure script dir: `New-Item -ItemType Directory -Force "$Env:UserProfile\bin" | Out-Null`
5. Set execution policy (user scope):
   ```powershell
   Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
   ```
6. Install & init Podman:
   ```powershell
   winget install RedHat.Podman
   podman machine init --cpus 2 --memory 4096 --disk-size 20
   podman machine start
   ```
7. Verify wrapper:
   ```powershell
   & $Env:UserProfile\bin\mcp-github-wrapper.ps1 --help | Select-Object -First 10
   ```
   If it errors about credentials, re-create the Generic Credential `GitHub`

**macOS (Keychain + Wrapper Script)**

1. Create a keychain item:
   - Open Keychain Access (⌘ + Space → "Keychain Access").
   - Select the `login` keychain & `Passwords` category.
   - File > New Password Item…
     - Name: `GitHub`
     - Account: your macOS username (must match `$USER`).
     - Password: your GitHub Personal Access Token.
   - Click Add.
2. Use the provided wrapper script: copy [`scripts/mcp-github-wrapper.sh`](scripts/mcp-github-wrapper.sh) to `~/bin/mcp-github-wrapper.sh`
3. Make it executable: `chmod +x ~/bin/mcp-github-wrapper.sh`
4. Test retrieval (optional): `security find-generic-password -s GitHub -a "$USER" -w`
5. Verify wrapper: `~/bin/mcp-github-wrapper.sh --help | head -5`

Notes:
* If Homebrew bash path differs, change shebang to `#!/bin/bash`.
* If keychain auto-locks after reboot: `security unlock-keychain login.keychain-db`.

Security rationale: Configuration keeps secrets exclusively in OS-provided secure storage; no plaintext tokens in versioned config files or scripts.

#### Bitbucket MCP Server (Local, Unofficial)

There is currently **no official Bitbucket MCP server**. To use Bitbucket with agents locally, use an **unofficial** server: [`@aashari/mcp-server-atlassian-bitbucket`](https://github.com/aashari/mcp-server-atlassian-bitbucket).

Key differences vs. GitHub MCP:
- GitHub + Atlassian (Jira/Confluence) offer hosted endpoints; Bitbucket does not.
- Bitbucket integration relies on a Bitbucket **App Password** (scoped minimally as needed) and your Bitbucket **username** (NOT your email address).
- Security: Store only the app password in secure OS storage (macOS Keychain or Windows Credential Manager); leave username as a plain variable in the wrapper script.

#### Creating a Bitbucket App Password

First, create an app password in Bitbucket with the required scopes:

1. Go to Personal Bitbucket Settings → App Passwords → Create app password (https://bitbucket.org/account/settings/app-passwords/)
2. Permissions needed (tick these):
   - **Account**
     - email
     - read
   - **Workspace membership:**
     - read
   - **Projects:**
     - read
   - **Repositories:**
     - read
     - write
   - **Pull requests:**
     - read
     - write
   - **Pipelines:**
     - read
   - **Runners:**
     - read

#### macOS Wrapper Script

1. Create a Keychain item for the app password only:
   - GUI: Keychain Access → File → New Password Item…
     - Name (Service): `bitbucket-mcp`
     - Account: `app-password`
     - Password: (your Bitbucket app password)
   - Or CLI:
     ```bash
     security add-generic-password -s "bitbucket-mcp" -a "app-password" -w "<app_password>"
     ```

2. Copy `scripts/mcp-bitbucket-wrapper.sh` to somewhere on your `$PATH` (or run in place):
   ```bash
   cp scripts/mcp-bitbucket-wrapper.sh ~/bin/
   ```
3. Make it executable:
   ```bash
   chmod +x ~/bin/mcp-bitbucket-wrapper.sh
   ```
4. Add to your agent configuration using the provided complete configurations:
   - **VS Code (macOS)**: Use [`scripts/vscode-mcp-config_macos.json`](scripts/vscode-mcp-config_macos.json)
   - **VS Code (Windows)**: Use [`scripts/vscode-mcp-config_windows.json`](scripts/vscode-mcp-config_windows.json)
   - **Claude Desktop (macOS)**: Use [`scripts/claude_desktop_config_macos.json`](scripts/claude_desktop_config_macos.json) 
   - **Claude Desktop (Windows)**: Use [`scripts/claude_desktop_config_windows.json`](scripts/claude_desktop_config_windows.json)
   
   **Important**: Replace `your-bitbucket-username` in the configuration with your actual Bitbucket username from https://bitbucket.org/account/settings/ ("Username" field, NOT email).
   
   Customize the paths for your username and merge with your existing configuration.
5. Test:
   ```bash
   ATLASSIAN_BITBUCKET_USERNAME="your-username" ~/bin/mcp-bitbucket-wrapper.sh --help | head -5
   ```

Environment overrides:
* `BITBUCKET_DEFAULT_WORKSPACE` (defaults to `Guttmacher`).
* `ATLASSIAN_BITBUCKET_APP_PASSWORD` (if set, overrides Keychain retrieval).

Security notes (macOS):
* Only app password stored in Keychain; username provided via JSON configuration.
* No secrets stored in scripts or configuration files.

#### Windows Wrapper Script (PowerShell)

Create a **Generic Credential** in Windows Credential Manager for app password only:
1. Control Panel → User Accounts → Credential Manager → Windows Credentials → Add a generic credential.
   - Internet or network address: `bitbucket-mcp`
   - User name: `app-password`
   - Password: (your Bitbucket app password)

Or via command line:
```powershell
cmd /c "cmdkey /add:bitbucket-mcp /user:app-password /pass:<app_password>"
```

Then install (if needed) the CredentialManager module to read the credentials:
```powershell
Install-Module CredentialManager -Scope CurrentUser -Force
```

Optionally set a workspace:
```powershell
$env:BITBUCKET_DEFAULT_WORKSPACE = 'Guttmacher'
```

Use the provided complete configurations and customize paths:
* **VS Code (Windows)**: [`scripts/vscode-mcp-config_windows.json`](scripts/vscode-mcp-config_windows.json)
* **Claude Desktop**: [`scripts/claude_desktop_config_windows.json`](scripts/claude_desktop_config_windows.json)

**Important**: Replace `your-bitbucket-username` in the configuration with your actual Bitbucket username from https://bitbucket.org/account/settings/ ("Username" field, NOT email).

Test:
```powershell
$env:ATLASSIAN_BITBUCKET_USERNAME="your-username"; & C:/path/to/scripts/mcp-bitbucket-wrapper.ps1 --help | Select-Object -First 5
```

Security notes (Windows):
* Only app password stored in Credential Manager; username provided via JSON configuration.
* No secrets stored in scripts or configuration files.
* Supports overriding password via `ATLASSIAN_BITBUCKET_APP_PASSWORD` env var for ephemeral sessions.

#### Minimal Manual Launch (Any OS)
If you prefer not to use secure credential storage, you can export variables then run via `npx` (NOT recommended for daily use):
```bash
export ATLASSIAN_BITBUCKET_USERNAME="<username>"
export ATLASSIAN_BITBUCKET_APP_PASSWORD="<app_password>"
export BITBUCKET_DEFAULT_WORKSPACE="Guttmacher"
npx -y @aashari/mcp-server-atlassian-bitbucket
```
Drawbacks: exposes credentials to shell history / process table.

#### Troubleshooting
| Symptom | Cause | Fix |
|---------|-------|-----|
| macOS: "Could not retrieve Bitbucket credentials" | Keychain item missing | Create keychain entry with service `bitbucket-mcp` |
| Windows: Credential not found | Generic credential not created | Add credential `bitbucket-mcp` in Credential Manager | 
| Username rejected | Using email instead of username | Use profile username from settings page | 
| 401 Unauthorized | Wrong app password scope / value | Regenerate app password with correct scopes | 

Scopes: Use the minimal scopes required by your workflows (e.g., repository read/write as needed). Avoid over-broad admin scopes.

### Agent Configuration

#### VS Code

For VS Code, use the complete configuration files that include all MCP servers:

**Manual Installation (Alternative):**
1. From the Command Palette, choose **MCP: Open User Configuration**
2. Use the provided configuration: copy [`scripts/vscode-mcp-config_macos.json`](scripts/vscode-mcp-config_macos.json) (macOS) or [`scripts/vscode-mcp-config_windows.json`](scripts/vscode-mcp-config_windows.json) (Windows) and customize paths as needed

#### Claude.ai

1. Open [Settings > Connectors](https://claude.ai/settings/connectors)
2. Press each the **Connect** button (next to Atlassian and GitHub)
Note: This adds the ability to add files from GitHub, but does not add the [GitHub MCP Server](https://github.com/github/github-mcp-server/blob/main/docs/installation-guides/install-claude.md).

#### Claude Desktop

When you connect MCP servers in Claude.ai, they automatically become available in Claude Desktop. Only add local servers here. For all MCP servers, always use secure secret retrieval (Keychain on macOS or Windows Credential Manager). Never paste access tokens directly into `claude_desktop_config.json`.

**Windows Configuration:**
Use the provided configuration: copy [`scripts/claude_desktop_config_windows.json`](scripts/claude_desktop_config_windows.json) and customize the username paths, then merge with your existing `claude_desktop_config.json`

**macOS Configuration:**
Use the provided configuration: copy [`scripts/claude_desktop_config_macos.json`](scripts/claude_desktop_config_macos.json) and customize the username paths, then merge with your existing `claude_desktop_config.json`


### Tool Availability Matrix

- Modes organized left-to-right from least to most privileges
- Review mode adds PR review + issue commenting over QnA, without broader planning artifact mutation.
- Plan mode extends Review with planning artifact creation/edit and PR creation/edit (no merge / branch ops).
- Code modes include full repository mutation (branches, merges, execution).
- See [Modes](#modes)

Note: "Code" shows toolsets for "Code - GPT-5" and "Code - Sonnet-4" modes.

📚 **For detailed tool descriptions, see the [Tools Glossary](TOOLS_GLOSSARY.md).**

Legend: ✅ available, ❌ unavailable in that mode.

| Tool | QnA | Review | Plan | Code |
|------|-----|--------|------|------|
| **Built-In (VS Code / Core)** | | | | |
| *Code & Project Navigation* | | | | |
| [codebase](TOOLS_GLOSSARY.md#codebase) | ✅ | ✅ | ✅ | ✅ |
| [findTestFiles](TOOLS_GLOSSARY.md#findtestfiles) | ✅ | ✅ | ✅ | ✅ |
| [search](TOOLS_GLOSSARY.md#search) | ✅ | ✅ | ✅ | ✅ |
| [searchResults](TOOLS_GLOSSARY.md#searchresults) | ✅ | ✅ | ✅ | ✅ |
| [usages](TOOLS_GLOSSARY.md#usages) | ✅ | ✅ | ✅ | ✅ |
| *Quality & Diagnostics* | | | | |
| [problems](TOOLS_GLOSSARY.md#problems) | ✅ | ✅ | ✅ | ✅ |
| [testFailure](TOOLS_GLOSSARY.md#testfailure) | ✅ | ✅ | ✅ | ✅ |
| *Version Control & Changes* | | | | |
| [changes](TOOLS_GLOSSARY.md#changes) | ✅ | ✅ | ✅ | ✅ |
| *Environment & Execution* | | | | |
| [terminalLastCommand](TOOLS_GLOSSARY.md#terminallastcommand) | ✅ | ✅ | ✅ | ✅ |
| [terminalSelection](TOOLS_GLOSSARY.md#terminalselection) | ❌ | ❌ | ❌ | ✅ |
| *Web & External Content* | | | | |
| [fetch](TOOLS_GLOSSARY.md#fetch) | ✅ | ✅ | ✅ | ✅ |
| [githubRepo](TOOLS_GLOSSARY.md#githubrepo) | ✅ | ✅ | ✅ | ✅ |
| *Editor & Extensions* | | | | |
| [extensions](TOOLS_GLOSSARY.md#extensions) | ❌ | ❌ | ❌ | ❌ |
| [vscodeAPI](TOOLS_GLOSSARY.md#vscodeapi) | ❌ | ❌ | ❌ | ❌ |
| *Editing & Automation* | | | | |
| [editFiles](TOOLS_GLOSSARY.md#editfiles) | ❌ | ❌ | ❌ | ✅ |
| [runCommands](TOOLS_GLOSSARY.md#runcommands) | ❌ | ❌ | ❌ | ✅ |
| [runTasks](TOOLS_GLOSSARY.md#runtasks) | ❌ | ❌ | ❌ | ✅ |
| **GitHub Pull Requests Extension (VS Code)** | | | | |
| [activePullRequest](TOOLS_GLOSSARY.md#activepullrequest) | ✅ | ✅ | ✅ | ✅ |
| [copilotCodingAgent](TOOLS_GLOSSARY.md#copilotcodingagent) | ❌ | ❌ | ❌ | ✅ |
| **Context7** | | | | |
| [resolve-library-id](TOOLS_GLOSSARY.md#resolve-library-id) | ✅ | ✅ | ✅ | ✅ |
| [get-library-docs](TOOLS_GLOSSARY.md#get-library-docs) | ✅ | ✅ | ✅ | ✅ |
| **Atlassian** | | | | |
| *Jira Issues & Operations* | | | | |
| [addCommentToJiraIssue](TOOLS_GLOSSARY.md#addcommenttojiraissue) | ❌ | ✅ | ✅ | ✅ |
| [createJiraIssue](TOOLS_GLOSSARY.md#createjiraissue) | ❌ | ❌ | ✅ | ✅ |
| [editJiraIssue](TOOLS_GLOSSARY.md#editjiraissue) | ❌ | ❌ | ✅ | ✅ |
| [getJiraIssue](TOOLS_GLOSSARY.md#getjiraissue) | ✅ | ✅ | ✅ | ✅ |
| [getJiraIssueRemoteIssueLinks](TOOLS_GLOSSARY.md#getjiraissueremoteissuelinks) | ✅ | ✅ | ✅ | ✅ |
| [getTransitionsForJiraIssue](TOOLS_GLOSSARY.md#gettransitionsforjiraissue) | ❌ | ❌ | ❌ | ❌ |
| [searchJiraIssuesUsingJql](TOOLS_GLOSSARY.md#searchjiraissuesusingjql) | ✅ | ✅ | ✅ | ✅ |
| [transitionJiraIssue](TOOLS_GLOSSARY.md#transitionjiraissue) | ❌ | ❌ | ✅ | ✅ |
| *Jira Project Metadata* | | | | |
| [getJiraProjectIssueTypesMetadata](TOOLS_GLOSSARY.md#getjiraprojectissuetypesmetadata) | ✅ | ✅ | ✅ | ✅ |
| [getVisibleJiraProjects](TOOLS_GLOSSARY.md#getvisiblejiraprojects) | ✅ | ✅ | ✅ | ✅ |
| *Confluence Pages & Content* | | | | |
| [createConfluencePage](TOOLS_GLOSSARY.md#createconfluencepage) | ❌ | ❌ | ✅ | ✅ |
| [getConfluencePage](TOOLS_GLOSSARY.md#getconfluencepage) | ✅ | ✅ | ✅ | ✅ |
| [getConfluencePageAncestors](TOOLS_GLOSSARY.md#getconfluencepageancestors) | ❌ | ❌ | ❌ | ❌ |
| [getConfluencePageDescendants](TOOLS_GLOSSARY.md#getconfluencepagedescendants) | ❌ | ❌ | ❌ | ❌ |
| [getPagesInConfluenceSpace](TOOLS_GLOSSARY.md#getpagesinconfluencespace) | ✅ | ✅ | ✅ | ✅ |
| [updateConfluencePage](TOOLS_GLOSSARY.md#updateconfluencepage) | ❌ | ❌ | ✅ | ✅ |
| *Confluence Comments* | | | | |
| [createConfluenceFooterComment](TOOLS_GLOSSARY.md#createconfluencefootercomment) | ❌ | ❌ | ✅ | ✅ |
| [createConfluenceInlineComment](TOOLS_GLOSSARY.md#createconfluenceinlinecomment) | ❌ | ❌ | ✅ | ✅ |
| [getConfluencePageFooterComments](TOOLS_GLOSSARY.md#getconfluencepagefootercomments) | ✅ | ✅ | ✅ | ✅ |
| [getConfluencePageInlineComments](TOOLS_GLOSSARY.md#getconfluencepageinlinecomments) | ✅ | ✅ | ✅ | ✅ |
| *Confluence Spaces & Discovery* | | | | |
| [getConfluenceSpaces](TOOLS_GLOSSARY.md#getconfluencespaces) | ✅ | ✅ | ✅ | ✅ |
| [searchConfluenceUsingCql](TOOLS_GLOSSARY.md#searchconfluenceusingcql) | ✅ | ✅ | ✅ | ✅ |
| *User & Identity* | | | | |
| [atlassianUserInfo](TOOLS_GLOSSARY.md#atlassianuserinfo) | ✅ | ✅ | ✅ | ✅ |
| [lookupJiraAccountId](TOOLS_GLOSSARY.md#lookupjiraaccountid) | ✅ | ✅ | ✅ | ✅ |
| *Other* | | | | |
| [getAccessibleAtlassianResources](TOOLS_GLOSSARY.md#getaccessibleatlassianresources) | ✅ | ✅ | ✅ | ✅ |
| **GitHub** | | | | |
| *Commits & Repository* | | | | |
| [create_branch](TOOLS_GLOSSARY.md#create_branch) | ❌ | ❌ | ❌ | ✅ |
| [create_repository](TOOLS_GLOSSARY.md#create_repository) | ❌ | ❌ | ❌ | ✅ |
| [get_commit](TOOLS_GLOSSARY.md#get_commit) | ✅ | ✅ | ✅ | ✅ |
| [get_file_contents](TOOLS_GLOSSARY.md#get_file_contents) | ✅ | ✅ | ✅ | ✅ |
| [get_tag](TOOLS_GLOSSARY.md#get_tag) | ❌ | ❌ | ❌ | ❌ |
| [list_branches](TOOLS_GLOSSARY.md#list_branches) | ✅ | ✅ | ✅ | ✅ |
| [list_commits](TOOLS_GLOSSARY.md#list_commits) | ✅ | ✅ | ✅ | ✅ |
| [list_tags](TOOLS_GLOSSARY.md#list_tags) | ❌ | ❌ | ❌ | ❌ |
| [push_files](TOOLS_GLOSSARY.md#push_files) | ❌ | ❌ | ❌ | ✅ |
| *Pull Requests  Retrieval* | | | | |
| [get_pull_request](TOOLS_GLOSSARY.md#get_pull_request) | ✅ | ✅ | ✅ | ✅ |
| [get_pull_request_comments](TOOLS_GLOSSARY.md#get_pull_request_comments) | ✅ | ✅ | ✅ | ✅ |
| [get_pull_request_diff](TOOLS_GLOSSARY.md#get_pull_request_diff) | ✅ | ✅ | ✅ | ✅ |
| [get_pull_request_files](TOOLS_GLOSSARY.md#get_pull_request_files) | ✅ | ✅ | ✅ | ✅ |
| [get_pull_request_reviews](TOOLS_GLOSSARY.md#get_pull_request_reviews) | ✅ | ✅ | ✅ | ✅ |
| [get_pull_request_status](TOOLS_GLOSSARY.md#get_pull_request_status) | ✅ | ✅ | ✅ | ✅ |
| [list_pull_requests](TOOLS_GLOSSARY.md#list_pull_requests) | ✅ | ✅ | ✅ | ✅ |
| *Pull Requests  Actions* | | | | |
| [add_comment_to_pending_review](TOOLS_GLOSSARY.md#add_comment_to_pending_review) | ❌ | ✅ | ✅ | ✅ |
| [create_pending_pull_request_review](TOOLS_GLOSSARY.md#create_pending_pull_request_review) | ❌ | ✅ | ✅ | ✅ |
| [create_pull_request](TOOLS_GLOSSARY.md#create_pull_request) | ❌ | ❌ | ✅ | ✅ |
| [create_pull_request_with_copilot](TOOLS_GLOSSARY.md#create_pull_request_with_copilot) | ❌ | ❌ | ❌ | ✅ |
| [merge_pull_request](TOOLS_GLOSSARY.md#merge_pull_request) | ❌ | ❌ | ❌ | ✅ |
| [request_copilot_review](TOOLS_GLOSSARY.md#request_copilot_review) | ❌ | ❌ | ❌ | ❌ |
| [submit_pending_pull_request_review](TOOLS_GLOSSARY.md#submit_pending_pull_request_review) | ❌ | ✅ | ✅ | ✅ |
| [update_pull_request](TOOLS_GLOSSARY.md#update_pull_request) | ❌ | ❌ | ✅ | ✅ |
| [update_pull_request_branch](TOOLS_GLOSSARY.md#update_pull_request_branch) | ❌ | ❌ | ❌ | ✅ |
| *Issues* | | | | |
| [add_issue_comment](TOOLS_GLOSSARY.md#add_issue_comment) | ❌ | ✅ | ✅ | ✅ |
| [create_issue](TOOLS_GLOSSARY.md#create_issue) | ❌ | ❌ | ✅ | ✅ |
| [get_issue](TOOLS_GLOSSARY.md#get_issue) | ✅ | ✅ | ✅ | ✅ |
| [get_issue_comments](TOOLS_GLOSSARY.md#get_issue_comments) | ✅ | ✅ | ✅ | ✅ |
| [list_issues](TOOLS_GLOSSARY.md#list_issues) | ✅ | ✅ | ✅ | ✅ |
| [search_issues](TOOLS_GLOSSARY.md#search_issues) | ✅ | ✅ | ✅ | ✅ |
| [update_issue](TOOLS_GLOSSARY.md#update_issue) | ❌ | ❌ | ✅ | ✅ |
| *Sub-Issues* | | | | |
| [list_sub_issues](TOOLS_GLOSSARY.md#list_sub_issues) | ✅ | ✅ | ✅ | ✅ |
| [reprioritize_sub_issue](TOOLS_GLOSSARY.md#reprioritize_sub_issue) | ❌ | ❌ | ✅ | ❌ |
| *Gists* | | | | |
| [list_gists](TOOLS_GLOSSARY.md#list_gists) | ❌ | ❌ | ❌ | ❌ |
| [update_gist](TOOLS_GLOSSARY.md#update_gist) | ❌ | ❌ | ❌ | ❌ |
| *Notifications* | | | | |
| [list_notifications](TOOLS_GLOSSARY.md#list_notifications) | ✅ | ✅ | ✅ | ✅ |
| *Code Scanning & Security* | | | | |
| [list_code_scanning_alerts](TOOLS_GLOSSARY.md#list_code_scanning_alerts) | ❌ | ❌ | ❌ | ❌ |
| *Workflows (GitHub Actions)* | | | | |
| [get_workflow_run](TOOLS_GLOSSARY.md#get_workflow_run) | ✅ | ❌ | ✅ | ✅ |
| [get_workflow_run_logs](TOOLS_GLOSSARY.md#get_workflow_run_logs) | ❌ | ❌ | ❌ | ❌ |
| [get_workflow_run_usage](TOOLS_GLOSSARY.md#get_workflow_run_usage) | ❌ | ❌ | ❌ | ❌ |
| [list_workflow_jobs](TOOLS_GLOSSARY.md#list_workflow_jobs) | ❌ | ❌ | ❌ | ❌ |
| [list_workflow_run_artifacts](TOOLS_GLOSSARY.md#list_workflow_run_artifacts) | ✅ | ❌ | ✅ | ✅ |
| [list_workflow_runs](TOOLS_GLOSSARY.md#list_workflow_runs) | ❌ | ❌ | ❌ | ❌ |
| [list_workflows](TOOLS_GLOSSARY.md#list_workflows) | ❌ | ❌ | ❌ | ❌ |
| [rerun_failed_jobs](TOOLS_GLOSSARY.md#rerun_failed_jobs) | ❌ | ❌ | ❌ | ❌ |
| [rerun_workflow_run](TOOLS_GLOSSARY.md#rerun_workflow_run) | ❌ | ❌ | ❌ | ❌ |
| *Search & Discovery* | | | | |
| [search_code](TOOLS_GLOSSARY.md#search_code) | ✅ | ✅ | ✅ | ✅ |
| [search_orgs](TOOLS_GLOSSARY.md#search_orgs) | ❌ | ❌ | ❌ | ❌ |
| [search_pull_requests](TOOLS_GLOSSARY.md#search_pull_requests) | ✅ | ✅ | ✅ | ✅ |
| [search_repositories](TOOLS_GLOSSARY.md#search_repositories) | ✅ | ✅ | ✅ | ✅ |
| [search_users](TOOLS_GLOSSARY.md#search_users) | ❌ | ❌ | ❌ | ❌ |
| *User & Account* | | | | |
| [get_me](TOOLS_GLOSSARY.md#get_me) | ✅ | ✅ | ✅ | ✅ |
| *File Operations* | | | | |
| [create_or_update_file](TOOLS_GLOSSARY.md#create_or_update_file) | ❌ | ❌ | ❌ | ✅ |

## Notes

- QnA mode excludes all mutating / execution capabilities. Plan mode excludes code / repo / execution capabilities but permits planning artifact mutations. Code mode includes full capabilities.
- This document is the canonical source for tool availability.
- Update the table and definitions together, and test that you made corresponding edits across this file and the chatmode.md files with `Rscript validate_tools.R`

## Repository Validation

This repository includes a validation script to ensure consistency between the Tool Availability Matrix in this README and the individual chatmode files:

**`validate_tools.R`**: Compares toolsets defined in `copilot/modes/*.chatmode.md` files against the matrix in this README.md. Run this script after making changes to either the matrix or the mode files to verify they remain synchronized.

```bash
Rscript validate_tools.R
```


## Using `code_style_guidelines.txt` Across Tools

### GitHub Copilot (Repository-Level)
1. Create or edit `.github/copilot-instructions.md`
2. Paste `code_style_guidelines.txt` content.

Reference: [Adding repository custom instructions for GitHub Copilot](https://docs.github.com/en/enterprise-cloud@latest/copilot/how-tos/configure-custom-instructions/add-repository-instructions)

### GitHub Copilot (GitHub.com Chats)

#### Organization-Level Instructions
**Note:** Organization custom instructions are currently only supported for GitHub Copilot Chat in GitHub.com and do not affect VS Code or other editors. For editor support, see [GitHub Copilot (Repository-Level)](#github-copilot-repository-level) above.

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
