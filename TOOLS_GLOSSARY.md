# Tools Glossary

This document provides detailed definitions for all tools referenced in the [Tool Availability Matrix](README.md#tool-availability-matrix).

**Note:** Definitions come from the MCP servers.

## Built-In (VS Code / Core)

### Code & Project Navigation

#### codebase
Search, read, and analyze project source code.

#### findTestFiles
Given a source (or test) file, locate its corresponding test (or source) counterpart.

#### search
Search and read files in the workspace.

#### searchResults
Access the current search view results programmatically.

#### usages
Find references, definitions, implementations, and other symbol usages.

### Quality & Diagnostics

#### problems
Retrieve diagnostics (errors/warnings) for a file.

#### testFailure
Surface details about the most recent unit test failure.

### Version Control & Changes

#### changes
Get diffs of locally changed files.

### Environment & Execution

#### terminalLastCommand
Return the last executed command in the active terminal.

#### terminalSelection
Return the currently selected text in the terminal (Code mode only).

### Web & External Content

#### fetch
Fetch main textual content from a web page (provide URL and optional query focus).

#### githubRepo
Search a public GitHub repository for relevant code snippets.

### Editor & Extensions

#### extensions
Discover or inspect installed/available editor extensions.

#### vscodeAPI
Query VS Code API references and docs (Code mode only).

### Editing & Automation

#### editFiles
Edit existing workspace files (Code mode only; mutating).

#### runCommands
Execute arbitrary shell/CLI commands in a persistent terminal (Code mode only).

#### runTasks
Create/run tasks (build/test/etc.) via tasks configuration (Code mode only).

## GitHub Pull Requests Extension (VS Code)

#### activePullRequest
Retrieve context for the currently focused pull request.

#### copilotCodingAgent
Completes the provided task using an asynchronous coding agent. Use when the user wants copilot to continue completing a task in the background or asynchronously. Launch an autonomous GitHub Copilot agent to work on coding tasks in the background. The agent will create a new branch, implement the requested changes, and open a pull request with the completed work.

## Context7

The [Context7 MCP Server](https://github.com/upstash/context7) retrieves up-to-date documentation and code examples for various programming languages and frameworks, from community-contributed sources (e.g., [ggplot2](https://context7.com/tidyverse/ggplot2)).

#### resolve-library-id
Resolve a package/library name to a Context7-compatible identifier.

#### get-library-docs
Retrieve up-to-date documentation snippets for a resolved library ID.

## Atlassian

The [Atlassian Remote MCP Server](https://support.atlassian.com/rovo/docs/getting-started-with-the-atlassian-remote-mcp-server/) provides lets an agent read/write from/to Jira and Confluence (but not Bitbucket).

### Jira Issues & Operations

#### addCommentToJiraIssue
Add a comment to a Jira issue.

#### createJiraIssue
Create a new Jira issue in a project.

#### editJiraIssue
Update fields of an existing Jira issue.

#### getJiraIssue
Fetch details for a Jira issue by key or ID.

#### getJiraIssueRemoteIssueLinks
Retrieve remote issue links (e.g., Confluence pages) tied to a Jira issue.

#### getTransitionsForJiraIssue
List available transitions for a Jira issue.

#### searchJiraIssuesUsingJql
Search Jira issues with JQL.

#### transitionJiraIssue
Move an issue through a workflow transition.

### Jira Project Metadata

#### getJiraProjectIssueTypesMetadata
Metadata/details for issue types in a Jira project.

#### getVisibleJiraProjects
List Jira projects visible to the user (permission-filtered).

### Confluence Pages & Content

#### createConfluencePage
Create a Confluence page (regular or live doc).

#### getConfluencePage
Fetch a Confluence page (body converted to Markdown).

#### getConfluencePageAncestors
List ancestor hierarchy for a page.

#### getConfluencePageDescendants
List descendant pages (optionally depth-limited).

#### getPagesInConfluenceSpace
List pages within a Confluence space.

#### updateConfluencePage
Update an existing Confluence page or live doc.

### Confluence Comments

#### createConfluenceFooterComment
Add a footer comment to a page/blog post.

#### createConfluenceInlineComment
Add an inline (text-anchored) comment to a page.

#### getConfluencePageFooterComments
List footer comments for a page.

#### getConfluencePageInlineComments
List inline comments for a page.

### Confluence Spaces & Discovery

#### getConfluenceSpaces
List spaces and related metadata.

#### searchConfluenceUsingCql
Query Confluence content using CQL.

### User & Identity

#### atlassianUserInfo
Get current Atlassian user identity info.

#### lookupJiraAccountId
Lookup account IDs by user name/email.

### Other

#### getAccessibleAtlassianResources
Discover accessible Atlassian cloud resources and obtain cloud IDs.

## GitHub

The [GitHub MCP Server](https://github.com/github/github-mcp-server) lets an agent read/write from/to GitHub.

### Commits & Repository

#### create_branch
Create a branch from a base ref (Code mode only).

#### create_repository
Create a new repository (mutation; Code mode only).

#### get_commit
Get details for a specific commit.

#### get_file_contents
Retrieve file or directory listing content from a repo.

#### get_tag
Get details for a tag.

#### list_branches
List branches in a repository.

#### list_commits
List commits on a branch or up to a commit SHA.

#### list_tags
List tags in a repository.

#### push_files
Push multiple files in a single commit (Code mode only).

### Pull Requests – Retrieval

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

#### list_pull_requests
List pull requests with filters.

### Pull Requests – Actions

#### add_comment_to_pending_review
Add a comment to an in-progress pending review (Code mode only).

#### create_pending_pull_request_review
Start a pending review (Code mode only).

#### create_pull_request
Open a new pull request (Code mode only).

#### create_pull_request_with_copilot
Delegate implementation task leading to a new PR (Code mode only).

#### merge_pull_request
Merge a pull request (Code mode only).

#### request_copilot_review
Request automated Copilot code review for a PR (Code mode only).

#### submit_pending_pull_request_review
Submit a pending review (Code mode only).

#### update_pull_request
Modify title/body/draft state of a pull request (Code mode only).

#### update_pull_request_branch
Update PR branch with base (Code mode only).

### Issues

#### add_issue_comment
Add a comment to a GitHub issue.

#### create_issue
Create a new GitHub issue in a repository.

#### get_issue
Retrieve details for a specific GitHub issue.

#### get_issue_comments
List comments on a GitHub issue.

#### list_issues
List issues in a repository with filtering options.

#### search_issues
Search for GitHub issues across repositories.

#### update_issue
Update title, body, state, or other properties of a GitHub issue.

### Sub-Issues

#### list_sub_issues
List sub-issues for a GitHub issue (Beta feature).

#### reprioritize_sub_issue
Reorder sub-issue priority (Code mode only).

### Gists

#### list_gists
List gists for a user.

#### update_gist
Update an existing gist (Code mode only).

### Notifications

#### list_notifications
List all notifications (filters optional).

### Code Scanning & Security

#### list_code_scanning_alerts
List code scanning alerts.

### Workflows (GitHub Actions)

#### get_workflow_run
Get details for a workflow run.

#### get_workflow_run_logs
Download logs (ZIP) for a workflow run.

#### get_workflow_run_usage
Get billable time/usage metrics for a run.

#### list_workflow_jobs
List jobs for a workflow run.

#### list_workflow_run_artifacts
List artifacts produced by a workflow run.

#### list_workflow_runs
List workflow runs with filtering options.

#### list_workflows
List workflows configured in a repository.

#### rerun_failed_jobs
Re-run only failed jobs in a run (Code mode only).

#### rerun_workflow_run
Re-run an entire workflow run (Code mode only).

### Search & Discovery

#### search_code
Global code search across GitHub.

#### search_orgs
Search for GitHub organizations.

#### search_pull_requests
Search pull requests across repositories.

#### search_repositories
Search for repositories by criteria.

#### search_users
Search for GitHub users.

### User & Account

#### get_me
Get details for the authenticated GitHub user.

### File Operations

#### create_or_update_file
Create or update a single file in a repository (Code mode only).
