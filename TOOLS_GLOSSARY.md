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

#### think
Use this tool to think deeply about the user's request and organize your thoughts. This tool helps improve response quality by allowing the model to consider the request carefully, brainstorm solutions, and plan complex tasks. It's particularly useful for:

1. Exploring repository issues and brainstorming bug fixes
2. Analyzing test results and planning fixes
3. Planning complex refactoring approaches
4. Designing new features and architecture
5. Organizing debugging hypotheses

The tool logs a summarized thought process for transparency but doesn't execute any code or make changes.

#### todos
Scan the workspace (or specified files) for TODO / FIXME / NOTE style comments and aggregate them into a structured list (file, line, tag, description). Useful for backlog grooming, debt triage, and planning follow-up tasks. Read-only and non-mutating.

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

The [Sooperset local Atlassian MCP Server](https://github.com/sooperset/mcp-atlassian) provides access to both Jira and Confluence through a local containerized server for improved reliability and performance.

### Atlassian Common

#### getAccessibleAtlassianResources
Get cloudId to construct Atlassian REST API calls and determine accessible Jira/Confluence resources for the authenticated account.

### Jira Issues & Operations

#### jira_add_comment
Add a comment to a Jira issue.

#### addCommentToJiraIssue
Adds a comment to an existing Jira issue id or key.

#### jira_create_issue
Create a new Jira issue in a project.

#### createJiraIssue
Create a new Jira issue in a given project with a given issue type.

#### jira_update_issue
Update fields of an existing Jira issue.

#### editJiraIssue
Update the details of an existing Jira issue id or key.

#### jira_get_issue
Fetch details for a Jira issue by key or ID.

#### getJiraIssue
Get the details of a Jira issue by issue id or key.

#### jira_search
Search Jira issues with JQL (Jira Query Language).

#### searchJiraIssuesUsingJql
Search Jira issues using Jira Query Language (JQL).

#### jira_transition_issue
Move an issue through a workflow transition.

#### transitionJiraIssue
Transition an existing Jira issue (that has issue id or key) to a new status.

#### jira_get_transitions
List available transitions for a Jira issue.

#### getTransitionsForJiraIssue
Get available transitions for an existing Jira issue id or key.

#### jira_delete_issue
Delete a Jira issue.

#### getJiraProjectIssueTypesMetadata
Get a page of issue type metadata for a specified project. The issue type metadata will be used to create issue

#### jira_get_link_types
Retrieve available issue link types (e.g., blocks, relates to) in Jira.

#### jira_get_project_versions
List versions/releases for a given Jira project.

#### jira_get_worklog
Retrieve worklog entries for a specified Jira issue.

#### jira_download_attachments
Download or retrieve metadata for attachments associated with a Jira issue.

#### jira_add_worklog
Add a worklog entry (time spent) to a Jira issue.

#### jira_link_to_epic
Associate / link an issue to an Epic (set Epic relationship) in Jira.

#### jira_create_issue_link
Create a link between two Jira issues using a given link type.

#### jira_create_remote_issue_link
Create a remote issue link (e.g., external resource reference) for a Jira issue.

#### getJiraIssueRemoteIssueLinks
Get remote issue links (eg: Confluence links etc...) of an existing Jira issue id or key.

### Jira Project & Board Operations

#### jira_get_all_projects
List all Jira projects visible to the user (permission-filtered).

#### getVisibleJiraProjects
Get visible Jira projects for which the user has either view, browse, edit or create permission on that project

#### jira_get_project_issues
Get issues for a specific Jira project.

#### jira_get_agile_boards
Get Agile/Scrum boards from Jira.

#### jira_get_board_issues
Get issues from a specific board.

#### jira_get_sprints_from_board
Get sprints from a specific board.

#### jira_get_sprint_issues
Get issues from a specific sprint.

#### jira_search_fields
Search available Jira fields with keyword matching.

#### jira_get_user_profile
Get user profile information from Jira.

#### lookupJiraAccountId
Lookup account ids of existing users in Jira based on the user's display name or email address.

#### atlassianUserInfo
Get current user info from Atlassian.

### Confluence Pages & Content

#### confluence_create_page
Create a Confluence page (regular or live doc).

#### createConfluencePage
Create a new page in Confluence. Can create regular pages or live docs.

#### confluence_get_page
Fetch a Confluence page (body converted to Markdown).

#### getConfluencePage
Get a specific page or live doc data (including body content) from Confluence.

#### getConfluencePageAncestors
Get all parent pages (ancestors) of a specific page in the hierarchy.

#### confluence_update_page
Update an existing Confluence page or live doc.

#### updateConfluencePage
Update an existing page or Live Doc in Confluence.

#### confluence_delete_page
Delete a Confluence page.

#### confluence_get_page_children
List child pages of a Confluence page.

#### getConfluencePageDescendants
Get all child pages (descendants) of a specific page in Confluence.

#### getConfluencePageFooterComments
Get footer comments for a Confluence page.

#### getConfluencePageInlineComments
Get inline comments for a Confluence page.

#### confluence_search
Query Confluence content using CQL (Confluence Query Language).

#### searchConfluenceUsingCql
Search content in Confluence using CQL (Confluence Query Language).

#### confluence_get_comments
Get comments on a Confluence page.

#### confluence_add_comment
Add a comment to a Confluence page.

#### createConfluenceFooterComment
Create a footer comment on a Confluence page or live doc.

#### createConfluenceInlineComment
Create an inline comment on a page or blog post. Inline comments are attached to specific text selections within the page content.

#### confluence_get_labels
Get labels for a Confluence page.

#### confluence_add_label
Add a label to a Confluence page.

#### confluence_search_user
Search for Confluence users.

#### getConfluenceSpaces
Get spaces from Confluence. Spaces are containers for pages and content.

#### getPagesInConfluenceSpace
Get all pages within a specific Confluence space. Useful for space-wide content audits.

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

### Organization & Teams

#### get_teams
Get details of the teams the user is a member of. Limited to organizations accessible with current credentials.

#### get_team_members
Get member usernames of a specific team in an organization. Limited to organizations accessible with current credentials.

#### list_issue_types
List available issue types for GitHub projects.

### File Operations

#### create_or_update_file
Create or update a single file in a repository (Code mode only).

## Bitbucket

### Workspaces

#### bb_ls_workspaces
Lists workspaces within your Bitbucket account. Returns workspace slugs, names, and membership role.

#### bb_get_workspace
Retrieves detailed information for a workspace, including membership, projects, and key metadata.

### Repositories

#### bb_ls_repos
Lists repositories within a workspace with optional filtering by role, project key, or query string.

#### bb_get_repo
Retrieves detailed information for a specific repository including owner, main branch, and recent pull requests.

#### bb_get_commit_history
Retrieves commit history for a repository with optional filtering by revision or file path.

#### bb_get_file
Retrieves the content of a file from a Bitbucket repository at a specific revision.

#### bb_list_branches
Lists branches in a repository with optional filtering and pagination.

#### bb_add_branch
Creates a new branch in a specified Bitbucket repository (Code mode only).

#### bb_clone_repo
Clones a Bitbucket repository to your local filesystem using SSH or HTTPS (Code mode only).

### Pull Requests

#### bb_ls_prs
Lists pull requests within a repository with filtering by state and text search.

#### bb_get_pr
Retrieves detailed information about a specific pull request including diff statistics and optionally comments.

#### bb_ls_pr_comments
Lists comments on a specific pull request, including both general and inline code comments.

#### bb_add_pr_comment
Adds a comment to a specific pull request with support for inline code comments (Review+ modes).

#### bb_add_pr
Creates a new pull request in a repository (Plan+ modes).

#### bb_update_pr
Updates an existing pull request's title and/or description (Plan+ modes).

#### bb_approve_pr
Approves a pull request, marking it as ready for merge (Code mode only).

#### bb_reject_pr
Requests changes on a pull request, marking it as requiring changes (Code mode only).

### Search

#### bb_search
Searches Bitbucket for content matching a query. Supports searching code, repositories, pull requests, or other content.

### Diff

#### bb_diff_branches
Shows changes between branches in a repository, comparing source branch relative to destination branch.

#### bb_diff_commits
Shows changes between specific commits in a repository.
