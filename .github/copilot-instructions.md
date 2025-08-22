# GitHub Copilot Agent Instructions

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the information here.

## Working Effectively

This is a documentation repository for GitHub Copilot modes and tools. All "building" and "testing" consists of validating documentation structure and markdown formatting.

**Bootstrap and validate the repository:**
- `cd /home/runner/work/agents/agents` (or repository root)
- **Lint markdown files:** Run `markdownlint /path/to/repo/README.md /path/to/repo/copilot/modes/*.md` -- takes < 1 second. NEVER CANCEL.
- **Verify git status:** `git --no-pager status && git --no-pager log --oneline -5` -- takes < 0.1 seconds. NEVER CANCEL.

## Validation

**CRITICAL VALIDATION SCENARIOS:** After making any changes to this repository, you MUST test the following complete end-to-end scenarios:

1. **Documentation Navigation Test:** Verify an agent can navigate the repository structure by reading README.md and understanding the mode hierarchy. Test with: `head -50 README.md | grep -E "(##|###)"` -- takes < 0.1 seconds.

2. **Mode File Structure Test:** Validate that all mode files follow correct format (YAML frontmatter with tools list and contract section). Check manually by viewing each file.

3. **Cross-Reference Validation:** Check that the tool matrix in README.md matches the tools lists in the individual mode files.

4. **Markdown Quality Check:** Run full markdown linting to ensure documentation quality. The linting will show many existing issues - this is expected and not blocking.

5. **Tools Lists Validation:** Ensure the tools list in README.md accurately reflects the tools lists in the chatmode.md files. Verify with: `Rscript scripts/smoke_rules.R`.

**NEVER CANCEL any validation command.** All validation operations complete in under 1 second.

## Common Tasks

### Repository Structure
```
./
./
├── README.md                         # Main documentation
├── llm_coding_style_guidelines.txt   # General coding style guidelines
├── TOOLS_GLOSSARY.md                 # Glossary of all available tools
├── copilot/
│   └── modes/
│       ├── QnA.chatmode.md                # Strict read-only Q&A / analysis (no mutations)
│       ├── Plan.chatmode.md               # Remote planning & artifact curation + PR create/edit/review (no merge/branch)
│       ├── Code-Sonnet4.chatmode.md       # Full coding, execution, PR + branch ops (Claude Sonnet 4 model)
│       ├── Code-GPT5.chatmode.md          # Full coding, execution, PR + branch ops (GPT-5 model)
│       ├── Review.chatmode.md             # PR & issue review feedback (comments only)
├── scripts/
│   ├── mcp-github-wrapper.sh        # macOS/Linux GitHub MCP wrapper script
│   ├── mcp-github-wrapper.ps1       # Windows GitHub MCP wrapper script
│   ├── mcp-atlassian-wrapper.sh     # macOS/Linux Atlassian MCP wrapper script
│   ├── mcp-atlassian-wrapper.ps1    # Windows Atlassian MCP wrapper script
│   ├── mcp-bitbucket-wrapper.sh     # macOS/Linux Bitbucket MCP wrapper script
│   └── mcp-bitbucket-wrapper.ps1    # Windows Bitbucket MCP wrapper script
├── templates/
│   ├── mcp_mac.json                       # MCP configuration for macOS (VS Code and Claude Desktop)
│   ├── mcp_win.json                       # MCP configuration for Windows (VS Code and Claude Desktop)
│   └── vscode-settings.jsonc              # VS Code user settings template (optional)
└── tests/
    ├── smoke_mcp_wrappers.py        # Smoke test runner for wrapper stdout (filters/validates stdout)
    ├── smoke_auth.sh                # Tests for authentication setup
    └── smoke_rules.R                # R script for validating tool lists/matrix consistency```

### Key File Contents and Patterns

**Mode File Format:**
Standard YAML frontmatter:
   ```markdown
   ---
   description: 'Mode Name'
   tools: [...]
   ---
   Contract: ...
   ```

**Tool Availability Matrix:** The README.md contains a comprehensive table showing which tools are available in which modes. Reference this instead of guessing tool availability.

**Key Relationships:**
- `llm_coding_guidelines.txt` is referenced as the canonical source for multi-tool custom instructions
- `.github/copilot-instructions.md` (this file) is referenced in Code.chatmode.md line 46
- Mode files define different privilege levels: QnA < Review < Plan < Code

### Frequently Needed Information

**Mode Capabilities:**
- **QnA Mode:** Read-only analysis, no mutations anywhere
- **Review Mode:** PR review comments + issue comments only
- **Plan Mode:** Planning artifacts + PR create/edit (no merge/branch ops)
- **Code-GPT5 Mode:** Full implementation including merge & branch operations (GPT-5 model)
- **Code-Sonnet4 Mode:** Full implementation including merge & branch operations (Claude Sonnet 4 model)

**Build/Test Commands:** This repository has no traditional build process. The validation workflow is:
1. Markdown linting: `markdownlint *.md **/*.md`  
2. Git status check: `git --no-pager status`

**Timing Expectations:**
- All validation operations: < 1 second
- Git operations: < 0.1 seconds  
- File reading/analysis: < 0.1 seconds
- Complete workflow validation: < 1 second total

## Key Navigation Points

**For understanding the repository:**
- Start with README.md lines 1-50 for overview and structure
- Check copilot/modes/ directory for mode definitions
- Reference Tool Availability Matrix in README.md for tool capabilities

**For making changes:**
- Always validate mode file format if editing .chatmode.md files
- Run markdown linting before committing
- Test documentation navigation scenarios
- Verify cross-references remain intact

**For debugging issues:**
- Check mode file YAML frontmatter syntax
- Verify tool lists in mode files match README.md matrix
- Validate contract sections exist in all mode files
- Ensure proper file permissions and structure

## Critical Warnings

**NEVER CANCEL any validation command** - all operations complete in under 1 second.

**ALWAYS test documentation navigation scenarios** after making changes to ensure agents can effectively use the repository.

**MAINTAIN cross-reference integrity** between README.md tool matrix and individual mode files.

**PRESERVE existing mode file formats** - some use standard YAML frontmatter, others use code-block wrappers. Do not change format without understanding implications.

This repository enables GitHub Copilot agents to work effectively across different modes with clear capability boundaries and tool availability.