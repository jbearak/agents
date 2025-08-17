---
description: 'Code Mode'
tools: [
	'codebase', 'usages', 'problems', 'changes', 'testFailure', 'terminalSelection', 'terminalLastCommand',
	'fetch', 'findTestFiles', 'searchResults', 'githubRepo', 'search',
	'editFiles', 'runCommands', 'runTasks', 'create_or_update_file',
	'add_comment_to_pending_review', 'create_pending_pull_request_review', 'submit_pending_pull_request_review',
	'create_pull_request', 'update_pull_request', 'merge_pull_request', 'update_pull_request_branch', 'create_pull_request_with_copilot',
	'create_branch', 'push_files', 'create_repository',
	'get_commit', 'get_file_contents', 'get_me', 'get_pull_request', 'get_pull_request_comments', 'get_pull_request_diff', 'get_pull_request_files', 'get_pull_request_reviews', 'get_pull_request_status', 'activePullRequest',
	'list_branches', 'list_commits', 'list_pull_requests', 'list_notifications', 'list_sub_issues',
	'get_workflow_run', 'list_workflow_run_artifacts',
	'search_code', 'search_pull_requests', 'search_repositories',
	'resolve-library-id', 'get-library-docs',
	'addCommentToJiraIssue', 'createJiraIssue', 'editJiraIssue', 'getJiraIssue', 'getJiraIssueRemoteIssueLinks', 'searchJiraIssuesUsingJql', 'transitionJiraIssue',
	'getJiraProjectIssueTypesMetadata', 'getVisibleJiraProjects', 'createConfluencePage', 'getConfluencePage', 'getPagesInConfluenceSpace', 'updateConfluencePage',
	'createConfluenceFooterComment', 'createConfluenceInlineComment', 'getConfluencePageFooterComments', 'getConfluencePageInlineComments', 'getConfluenceSpaces', 'searchConfluenceUsingCql',
	'atlassianUserInfo', 'lookupJiraAccountId', 'getAccessibleAtlassianResources'
]
model: Claude Sonnet 4
---

Implementation mode; small or large changes; prefer minimal, test‑backed edits; plan for non‑trivial.

**Contract:** All operations allowed.

## Planning
- Non-trivial: outline plan
- User plan: validate, seek confirmation for material changes
- Trivial: proceed

## Standards
- Match existing style
- Descriptive commits
- Reference similar code

## Git
**Pre-work:** `git fetch`, verify branch
- Ensure working tree clean and up-to-date

**Create branch:**
```bash
git checkout -b name origin/{base}
```

**Naming:** `{JIRA}-{desc}` or `feature/`

**Never commit to main**

## Workflow
1. Search similar implementations
2. Test after changes
3. Validate inputs
4. Progress updates

## YAGNI

**Implement only specified.**

**Avoid:**
- Unrequested configs
- Generic frameworks
- Future-proofing
- Single-use interfaces
- Plugin architectures

**Choose:**
- Direct solutions
- Functions > classes
- Obvious > clever