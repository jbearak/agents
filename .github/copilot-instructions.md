# GitHub Copilot Agent Instructions

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the information here.

## Working Effectively

This is a documentation repository for GitHub Copilot modes and tools. All "building" and "testing" consists of validating documentation structure and markdown formatting.

**Bootstrap and validate the repository:**
- `cd /home/runner/work/agents/agents` (or repository root)
- **Validate documentation structure:** `python3 /tmp/test-scenario/validate-repository.py` -- takes < 0.1 seconds. NEVER CANCEL.
- **Lint markdown files:** Install markdownlint first with `mkdir -p /tmp/validation && cd /tmp/validation && npm init -y && npm install markdownlint-cli`, then run `./node_modules/.bin/markdownlint /path/to/repo/README.md /path/to/repo/copilot/modes/*.md` -- takes < 1 second. NEVER CANCEL.
- **Verify git status:** `git --no-pager status && git --no-pager log --oneline -5` -- takes < 0.1 seconds. NEVER CANCEL.

## Validation

**CRITICAL VALIDATION SCENARIOS:** After making any changes to this repository, you MUST test the following complete end-to-end scenarios:

1. **Documentation Navigation Test:** Verify an agent can navigate the repository structure by reading README.md and understanding the mode hierarchy. Test with: `head -50 README.md | grep -E "(##|###)"` -- takes < 0.1 seconds.

2. **Mode File Structure Test:** Validate that all mode files follow correct format (YAML frontmatter with tools list and contract section). Test with the validation script above.

3. **Cross-Reference Validation:** Ensure `.github/copilot-instructions.md` is properly referenced in `copilot/modes/Code.chatmode.md` on line 45. Verify with: `grep -n "copilot-instructions.md" copilot/modes/Code.chatmode.md`

4. **Markdown Quality Check:** Run full markdown linting to ensure documentation quality. The linting will show many existing issues - this is expected and not blocking.

**NEVER CANCEL any validation command.** All validation operations complete in under 1 second.

## Common Tasks

### Repository Structure
```
./
├── README.md               # Main documentation (2773 words, 417 lines)
├── coding_guidelines.txt   # Shared custom instructions for coding standards saved to https://github.com/organizations/Guttmacher/settings/copilot/custom_instructions
└── copilot/
    └── modes/
        ├── Question.chatmode.md     # Read-only Q&A mode (55 lines)
        ├── Plan.chatmode.md    # Planning mode (73 lines)
        ├── Review.chatmode.md  # Review mode (67 lines)
        └── Code.chatmode.md    # Full implementation mode (102 lines)
```

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
- `coding_guidelines.txt` is referenced as the canonical source for multi-tool custom instructions
- `.github/copilot-instructions.md` (this file) is referenced in Code.chatmode.md line 45
- Mode files define different privilege levels: Question < Review < Plan < Code

### Frequently Needed Information

**Mode Capabilities:**
- **Question Mode:** Read-only analysis, no mutations anywhere
- **Review Mode:** PR review comments + issue comments only
- **Plan Mode:** Planning artifacts + PR create/edit (no merge/branch ops)
- **Code Mode:** Full implementation including merge & branch operations

**Build/Test Commands:** This repository has no traditional build process. The validation workflow is:
1. Structure validation: `python3 /tmp/test-scenario/validate-repository.py`
2. Markdown linting: `markdownlint *.md **/*.md`  
3. Git status check: `git --no-pager status`

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