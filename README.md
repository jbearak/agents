# Modes & Tools Reference

Centralized documentation for Copilot modes, tool availability, and cross-tool custom instruction usage.

## Repository Structure

```
./
├── coding_guidelines.txt   # Source of shared custom instructions (org-wide & multi-tool)
├── README.md               # This documentation (modes, matrix, tool definitions)
└── copilot/
	└── modes/
		├── Plan.chatmode.md  # Read-only "Plan" / Ask mode definition (no mutations)
		└── Code.chatmode.md  # Full coding mode with editing & execution tools
```

## Modes Overview

| Mode | Purpose | Mutation | File | Contract Summary |
|------|---------|----------|------|------------------|
| Plan | Exploration, analysis, planning, answering questions | No | `copilot/modes/Plan.chatmode.md` | Read-only: must not change files or remote state |
| Code | Implementing, editing, running tests/commands | Yes (scoped & minimal) | `copilot/modes/Code.chatmode.md` | May edit & run; keep changes minimal & validated |

Plan mode tool list is limited to read-only retrieval and inspection. Code mode extends that list with mutation and execution capabilities.

## Tool Availability Matrix

Legend: ✅ available, ❌ unavailable in that mode.

| Tool | Plan Mode | Code Mode |
|------|-----------|-----------|
| **Built-In (VS Code / Core)** |||
| [codebase](#codebase) | ✅ | ✅ |
| [usages](#usages) | ✅ | ✅ |
| [search](#search) | ✅ | ✅ |
| [searchResults](#searchresults) | ✅ | ✅ |
| [findTestFiles](#findtestfiles) | ✅ | ✅ |
| [problems](#problems) | ✅ | ✅ |
| [changes](#changes) | ✅ | ✅ |
| [testFailure](#testfailure) | ✅ | ✅ |
| [terminalLastCommand](#terminallastcommand) | ✅ | ✅ |
| [terminalSelection](#terminalselection) | ❌ | ✅ |
| [fetch](#fetch) | ✅ | ✅ |
| [githubRepo](#githubrepo) | ✅ | ✅ |
| [extensions](#extensions) | ✅ | ✅ |
| [vscodeAPI](#vscodeapi) | ❌ | ✅ |
| [editFiles](#editfiles) | ❌ | ✅ |
| [runCommands](#runcommands) | ❌ | ✅ |
| [runTasks](#runtasks) | ❌ | ✅ |
| **Context7** |||
| [resolve-library-id](#resolve-library-id) | ✅ | ✅ |
| [get-library-docs](#get-library-docs) | ✅ | ✅ |
| **Atlassian** |||
| [atlassianUserInfo](#atlassianuserinfo) | ✅ | ✅ |
| [lookupJiraAccountId](#lookupjiraaccountid) | ✅ | ✅ |
| [getAccessibleAtlassianResources](#getaccessibleatlassianresources) | ✅ | ✅ |
| [createJiraIssue](#createjiraissue) | ✅ | ✅ |
| [editJiraIssue](#editjiraissue) | ✅ | ✅ |
| [getJiraIssue](#getjiraissue) | ✅ | ✅ |
| [transitionJiraIssue](#transitionjiraissue) | ✅ | ✅ |
| [addCommentToJiraIssue](#addcommenttojiraissue) | ✅ | ✅ |
| [getTransitionsForJiraIssue](#gettransitionsforjiraissue) | ✅ | ✅ |
| [getJiraIssueRemoteIssueLinks](#getjiraissueremoteissuelinks) | ✅ | ✅ |
| [searchJiraIssuesUsingJql](#searchjiraissuesusingjql) | ✅ | ✅ |
| [getVisibleJiraProjects](#getvisiblejiraprojects) | ✅ | ✅ |
| [getJiraProjectIssueTypesMetadata](#getjiraprojectissuetypesmetadata) | ✅ | ✅ |
| [createConfluencePage](#createconfluencepage) | ✅ | ✅ |
| [updateConfluencePage](#updateconfluencepage) | ✅ | ✅ |
| [getConfluencePage](#getconfluencepage) | ✅ | ✅ |
| [getPagesInConfluenceSpace](#getpagesinconfluencespace) | ✅ | ✅ |
| [getConfluencePageAncestors](#getconfluencepageancestors) | ✅ | ✅ |
| [getConfluencePageDescendants](#getconfluencepagedescendants) | ✅ | ✅ |
| [createConfluenceFooterComment](#createconfluencefootercomment) | ✅ | ✅ |
| [createConfluenceInlineComment](#createconfluenceinlinecomment) | ✅ | ✅ |
| [getConfluencePageFooterComments](#getconfluencepagefootercomments) | ✅ | ✅ |
| [getConfluencePageInlineComments](#getconfluencepageinlinecomments) | ✅ | ✅ |
| [getConfluenceSpaces](#getconfluencespaces) | ✅ | ✅ |
| [searchConfluenceUsingCql](#searchconfluenceusingcql) | ✅ | ✅ |
| **GitHub** |||
| [activePullRequest](#activepullrequest) | ✅ | ✅ |
| [get_commit](#get_commit) | ✅ | ✅ |
| [get_file_contents](#get_file_contents) | ✅ | ✅ |
| [list_branches](#list_branches) | ✅ | ✅ |
| [list_commits](#list_commits) | ✅ | ✅ |
| [get_tag](#get_tag) | ✅ | ✅ |
| [list_tags](#list_tags) | ✅ | ✅ |
| [create_repository](#create_repository) | ❌ | ✅ |
| [create_branch](#create_branch) | ❌ | ✅ |
| [push_files](#push_files) | ❌ | ✅ |
| [get_pull_request](#get_pull_request) | ✅ | ✅ |
| [get_pull_request_comments](#get_pull_request_comments) | ✅ | ✅ |
| [get_pull_request_diff](#get_pull_request_diff) | ✅ | ✅ |
| [get_pull_request_files](#get_pull_request_files) | ✅ | ✅ |
| [get_pull_request_reviews](#get_pull_request_reviews) | ✅ | ✅ |
| [get_pull_request_status](#get_pull_request_status) | ✅ | ✅ |
| [create_pull_request](#create_pull_request) | ❌ | ✅ |
| [update_pull_request](#update_pull_request) | ❌ | ✅ |
| [update_pull_request_branch](#update_pull_request_branch) | ❌ | ✅ |
| [merge_pull_request](#merge_pull_request) | ❌ | ✅ |
| [create_pending_pull_request_review](#create_pending_pull_request_review) | ❌ | ✅ |
| [add_comment_to_pending_review](#add_comment_to_pending_review) | ❌ | ✅ |
| [submit_pending_pull_request_review](#submit_pending_pull_request_review) | ❌ | ✅ |
| [request_copilot_review](#request_copilot_review) | ❌ | ✅ |
| [create_pull_request_with_copilot](#create_pull_request_with_copilot) | ❌ | ✅ |
| [list_pull_requests](#list_pull_requests) | ✅ | ✅ |
| [list_sub_issues](#list_sub_issues) | ✅ | ✅ |
| [reprioritize_sub_issue](#reprioritize_sub_issue) | ❌ | ✅ |
| [list_gists](#list_gists) | ✅ | ✅ |
| [update_gist](#update_gist) | ❌ | ✅ |
| [list_notifications](#list_notifications) | ✅ | ✅ |
| [list_code_scanning_alerts](#list_code_scanning_alerts) | ✅ | ✅ |
| [search_code](#search_code) | ✅ | ✅ |
| [search_pull_requests](#search_pull_requests) | ✅ | ✅ |
| [search_repositories](#search_repositories) | ✅ | ✅ |
| [search_users](#search_users) | ✅ | ✅ |
| [search_orgs](#search_orgs) | ✅ | ✅ |
| [get_workflow_run](#get_workflow_run) | ✅ | ✅ |
| [get_workflow_run_logs](#get_workflow_run_logs) | ✅ | ✅ |
| [get_workflow_run_usage](#get_workflow_run_usage) | ✅ | ✅ |
| [list_workflow_runs](#list_workflow_runs) | ✅ | ✅ |
| [list_workflows](#list_workflows) | ✅ | ✅ |
| [list_workflow_jobs](#list_workflow_jobs) | ✅ | ✅ |
| [list_workflow_run_artifacts](#list_workflow_run_artifacts) | ✅ | ✅ |
| [rerun_failed_jobs](#rerun_failed_jobs) | ❌ | ✅ |
| [rerun_workflow_run](#rerun_workflow_run) | ❌ | ✅ |

## Using `coding_guidelines.txt` Across Tools

### GitHub Copilot (Organization-Level)
1. Org admin navigates to GitHub: Settings > (Organization) > Copilot > Policies / Custom Instructions.
2. Open Custom Instructions editor and paste the full contents of `coding_guidelines.txt`.
3. Save; changes propagate to organization members (may require editor reload).
4. Version control: treat this repository file as the single source of truth; update here first, then re-paste.

### GitHub Copilot (User-Level Fallback)
If org-level not available: GitHub profile > Settings > Copilot > Personalized suggestions / Custom Instructions. Paste same contents; note these may be overridden by org policy later.

### Warp
1. Open Warp Settings > AI / Copilot (name may vary by version).
2. Locate Custom Instructions / System Prompt field.
3. Paste `coding_guidelines.txt` content.
4. Re-open any AI panels to ensure reload.

### Q (Per-Project Assumption)
Some AI assistants named "Q" load per-repo instruction files. Assumed pattern (adjust to actual implementation): place a copy (or symlink) at `./q/instructions.md` or `.q/instructions.md` within each repository. Keep it identical to `coding_guidelines.txt` to avoid drift.

### Synchronization Tips
- Track changes via normal PR review in this repo.
- When updating external destinations, include commit SHA in the external UI notes.
- Avoid editing in multiple places; always edit the canonical file then propagate.

## Anchored Tool Definitions

### Built-In (VS Code / Core)

#### codebase
Search, read, and analyze project source code.

#### usages
Find references, definitions, implementations, and other symbol usages.

#### search
Search and read files in the workspace.

#### searchResults
Access the current search view results programmatically.

#### findTestFiles
Given a source (or test) file, locate its corresponding test (or source) counterpart.

#### problems
Retrieve diagnostics (errors/warnings) for a file.

#### changes
Get diffs of locally changed files.

#### testFailure
Surface details about the most recent unit test failure.

#### terminalLastCommand
Return the last executed command in the active terminal.

#### terminalSelection
Return the currently selected text in the terminal (Code mode only).

#### fetch
Fetch main textual content from a web page (provide URL and optional query focus).

#### githubRepo
Search a public GitHub repository for relevant code snippets.

#### extensions
Discover or inspect installed/available editor extensions.

#### vscodeAPI
Query VS Code API references and docs (Code mode only).

#### editFiles
Edit existing workspace files (Code mode only; mutating).

#### runCommands
Execute arbitrary shell/CLI commands in a persistent terminal (Code mode only).

#### runTasks
Create/run tasks (build/test/etc.) via tasks configuration (Code mode only).

### Context7

#### resolve-library-id
Resolve a package/library name to a Context7-compatible identifier.

#### get-library-docs
Retrieve up-to-date documentation snippets for a resolved library ID.

### Atlassian

#### createJiraIssue
Create a new Jira issue in a project.

#### editJiraIssue
Update fields of an existing Jira issue.

#### getJiraIssue
Fetch details for a Jira issue by key or ID.

#### transitionJiraIssue
Move an issue through a workflow transition.

#### addCommentToJiraIssue
Add a comment to a Jira issue.

#### getTransitionsForJiraIssue
List available transitions for a Jira issue.

#### getJiraIssueRemoteIssueLinks
Retrieve remote issue links (e.g., Confluence pages) tied to a Jira issue.

#### searchJiraIssuesUsingJql
Search Jira issues with JQL.

#### getVisibleJiraProjects
List Jira projects visible to the user (permission-filtered).

#### getJiraProjectIssueTypesMetadata
Metadata/details for issue types in a Jira project.

#### createConfluencePage
Create a Confluence page (regular or live doc).

#### updateConfluencePage
Update an existing Confluence page or live doc.

#### getConfluencePage
Fetch a Confluence page (body converted to Markdown).

#### getPagesInConfluenceSpace
List pages within a Confluence space.

#### getConfluencePageAncestors
List ancestor hierarchy for a page.

#### getConfluencePageDescendants
List descendant pages (optionally depth-limited).

#### createConfluenceFooterComment
Add a footer comment to a page/blog post.

#### createConfluenceInlineComment
Add an inline (text-anchored) comment to a page.

#### getConfluencePageFooterComments
List footer comments for a page.

#### getConfluencePageInlineComments
List inline comments for a page.

#### getConfluenceSpaces
List spaces and related metadata.

#### searchConfluenceUsingCql
Query Confluence content using CQL.

#### atlassianUserInfo
Get current Atlassian user identity info.

#### lookupJiraAccountId
Lookup account IDs by user name/email.

#### getAccessibleAtlassianResources
Discover accessible Atlassian cloud resources and obtain cloud IDs.

### GitHub

#### activePullRequest
Retrieve context for the currently focused pull request.

#### get_commit
Get details for a specific commit.

#### get_file_contents
Retrieve file or directory listing content from a repo.

#### list_branches
List branches in a repository.

#### list_commits
List commits on a branch or up to a commit SHA.

#### get_tag
Get details for a tag.

#### list_tags
List tags in a repository.

#### create_repository
Create a new repository (mutation; Code mode only).

#### create_branch
Create a branch from a base ref (Code mode only).

#### push_files
Push multiple files in a single commit (Code mode only).

#### get_pull_request
Retrieve pull request details.

#### get_pull_request_comments
List comments on a pull request.

#### get_pull_request_diff
Retrieve a diff for a pull request.

#### get_pull_request_files
List changed files in a pull request.

#### get_pull_request_reviews
List reviews on a pull request.

#### get_pull_request_status
Fetch status checks for a pull request.

#### create_pull_request
Open a new pull request (Code mode only).

#### update_pull_request
Modify title/body/draft state of a pull request (Code mode only).

#### update_pull_request_branch
Update PR branch with base (Code mode only).

#### merge_pull_request
Merge a pull request (Code mode only).

#### create_pending_pull_request_review
Start a pending review (Code mode only).

#### add_comment_to_pending_review
Add a comment to an in-progress pending review (Code mode only).

#### submit_pending_pull_request_review
Submit a pending review (Code mode only).

#### request_copilot_review
Request automated Copilot code review for a PR (Code mode only).

#### create_pull_request_with_copilot
Delegate implementation task leading to a new PR (Code mode only).

#### list_pull_requests
List pull requests with filters.

#### list_sub_issues
List sub-issues for a GitHub issue (Beta feature).

#### reprioritize_sub_issue
Reorder sub-issue priority (Code mode only).

#### list_gists
List gists for a user.

#### update_gist
Update an existing gist (Code mode only).

#### list_notifications
List all notifications (filters optional).

#### list_code_scanning_alerts
List code scanning alerts.

#### search_code
Global code search across GitHub.

#### search_pull_requests
Search pull requests across repositories.

#### search_repositories
Search for repositories by criteria.

#### search_users
Search for GitHub users.

#### search_orgs
Search for GitHub organizations.

#### get_workflow_run
Get details for a workflow run.

#### get_workflow_run_logs
Download logs (ZIP) for a workflow run.

#### get_workflow_run_usage
Get billable time/usage metrics for a run.

#### list_workflow_runs
List workflow runs with filtering options.

#### list_workflows
List workflows configured in a repository.

#### list_workflow_jobs
List jobs for a workflow run.

#### list_workflow_run_artifacts
List artifacts produced by a workflow run.

#### rerun_failed_jobs
Re-run only failed jobs in a run (Code mode only).

#### rerun_workflow_run
Re-run an entire workflow run (Code mode only).

#### update_pull_request_branch
Bring a PR branch up to date with its base (Code mode only).

## Notes
- Some tools appear in multiple conceptual groups; each tool has a dedicated anchor for direct linking.
- Plan mode intentionally excludes all mutating / execution capabilities.
- This document is the canonical source for tool availability; update table and definitions together.
