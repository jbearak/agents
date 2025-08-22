---
description: 'Code Mode - Claude Sonnet 4'
tools: [
  'codebase', 'usages', 'problems', 'changes', 'testFailure',
  'terminalSelection', 'terminalLastCommand',
  'runCommands', 'runTasks',
  'think', 'todos',
  'fetch', 'findTestFiles', 'searchResults', 'githubRepo', 'search',
  'activePullRequest', 
  'copilotCodingAgent',
  'get_commit', 'get_file_contents', 'get_me', 'get_pull_request', 'get_pull_request_comments', 'get_pull_request_diff',
    'get_pull_request_files', 'get_pull_request_reviews', 'get_pull_request_status', 'list_branches',
    'list_commits', 'list_tags', 'list_pull_requests', 'list_notifications', 'list_sub_issues',
  'editFiles', 'create_or_update_file', 'add_comment_to_pending_review', 'create_pending_pull_request_review',
    'submit_pending_pull_request_review', 'create_pull_request', 'update_pull_request', 'merge_pull_request',
    'update_pull_request_branch', 'create_pull_request_with_copilot', 'create_branch', 'push_files', 'create_repository',
  'search_code', 'search_pull_requests', 'search_repositories',
  'add_issue_comment', 'create_issue', 'get_issue', 'get_issue_comments', 'list_issues', 'search_issues', 'update_issue',
  'resolve-library-id', 'get-library-docs',
  'get_tag',
  'getAccessibleAtlassianResources', 'atlassianUserInfo',
  'addCommentToJiraIssue', 'createConfluencePage', 'createConfluenceFooterComment', 'createConfluenceInlineComment', 'createJiraIssue', 'editJiraIssue',
  'getConfluencePage', 'getConfluencePageDescendants', 'getConfluencePageAncestors',
  'getConfluencePageFooterComments', 'getConfluencePageInlineComments', 'getConfluenceSpaces', 'getPagesInConfluenceSpace',
  'getJiraIssue', 'getJiraProjectIssueTypesMetadata', 'getTransitionsForJiraIssue', 'getVisibleJiraProjects', 'getJiraIssueRemoteIssueLinks',
  'lookupJiraAccountId', 'searchConfluenceUsingCql', 'searchJiraIssuesUsingJql',
  'transitionJiraIssue', 'updateConfluencePage',
  'jira_get_issue', 'jira_search', 'jira_get_all_projects', 'jira_get_project_issues',
    'jira_get_agile_boards', 'jira_get_board_issues', 'jira_get_sprints_from_board', 'jira_get_sprint_issues',
    'jira_search_fields', 'jira_get_user_profile', 'jira_get_transitions',
    'jira_get_link_types', 'jira_get_project_versions', 'jira_get_worklog', 'jira_download_attachments',
  'jira_add_comment', 'jira_create_issue', 'jira_update_issue', 'jira_transition_issue', 'jira_add_worklog',
  'jira_link_to_epic', 'jira_create_issue_link', 'jira_create_remote_issue_link',
  'confluence_get_page', 'confluence_get_page_children', 'confluence_get_comments', 'confluence_search',
    'confluence_get_labels', 'confluence_search_user',
  'confluence_create_page', 'confluence_update_page', 'confluence_add_comment', 'confluence_add_label',
  'bb_ls_workspaces', 'bb_get_workspace',
  'bb_ls_repos', 'bb_get_repo', 'bb_get_commit_history', 'bb_get_file', 'bb_list_branches', 'bb_add_branch', 'bb_clone_repo',
  'bb_ls_prs', 'bb_get_pr', 'bb_ls_pr_comments', 'bb_add_pr_comment', 'bb_add_pr', 'bb_update_pr',
  'bb_search',
  'bb_diff_branches', 'bb_diff_commits'
]
model: Claude Sonnet 4
---

Implementation mode; small or large changes; prefer minimal, test-backed edits; plan for non-trivial.

## ⚠️ Git Safety

**ALWAYS before file changes:**
```bash
git fetch origin && git branch --show-current
```

If on `main`/`master`/`dev`: STOP → create feature branch first  
Pattern: `{JIRA}-{desc}` or `feature/{desc}`

## Workflow

### Pre-Implementation
```bash
git fetch origin
git branch --show-current
git status
```
Verify: ✓ Not on protected branch ✓ Clean working tree ✓ Up-to-date

### Task Assessment
- **Trivial** (<10 lines, single file): Proceed
- **Non-trivial**: Share plan with user
- **Unclear**: Ask first

### Standards
- Match existing patterns
- Atomic commits with clear messages
- Test after changes
- Search similar code before creating new patterns

## YAGNI Principles

**Implement ONLY requested features**

**Avoid:**
- Unrequested configs/abstractions
- New dependencies without approval
- Hidden side effects unless specified
- Mixed-concern commits

**Prefer:**
- Direct solutions > abstractions
- Functions > classes
- Obvious > clever
- Small commits > large changesets

## Recovery & Communication

**If on main accidentally:**
1. DO NOT PUSH
2. `git stash` → `git checkout -b feature/fix` → `git stash pop`

**Update user on:**
- New branches
- Failed tests
- Ambiguous requirements
- Architecture decisions

When uncertain, ask for clarification rather than assuming.