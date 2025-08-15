# Modes & Tools Reference

Centralized documentation for Copilot modes, tool availability, and cross-tool custom instruction usage.

## Table of Contents

- [Repository Structure](#repository-structure)
- [Modes Overview](#modes-overview)
- [Tool Availability Matrix](#tool-availability-matrix)
- [Notes](#notes)
- [Using `coding_guidelines.txt` Across Tools](#using-coding_guidelinestxt-across-tools)
	- [GitHub Copilot (Organization-Level)](#github-copilot-organization-level)
	- [GitHub Copilot (Repository-Level)](#github-copilot-repository-level)
	- [Warp (User-Level)](#warp-user-level)
	- [Q (Repository-Level)](#q-repository-level)
	- [Claude Code (Repository-Level)](#claude-code-repository-level)
- [Tool Definitions](#tool-definitions)
	- [Built-In (VS Code / Core)](#built-in-vs-code--core)
	- [Context7](#context7)
	- [Atlassian](#atlassian)
	- [GitHub](#github)

## Repository Structure

```
./
├── coding_guidelines.txt   # Source of shared custom instructions (org-wide & multi-tool)
├── README.md               # This documentation (modes, matrix, tool definitions)
└── copilot/
	└── modes/
		├── Question.chatmode.md     # Strict read-only Q&A / analysis (no mutations)
		├── Plan.chatmode.md    # Remote planning & artifact curation + PR create/edit/review (no merge/branch)
		├── Review.chatmode.md  # PR & issue review feedback (comments only)
		└── Code.chatmode.md    # Full coding, execution, PR + branch ops
```

## Modes Overview

| Feature / Capability | Question | Plan | Review | Code |
|----------------------|-----|------|--------|------|
| Purpose | Q&A, exploration, explain code, gather context | Plan work, refine scope, shape tickets/pages, organize PR scaffolding | Provide review feedback on PRs / issues | Implement changes, run tests/commands |
| Local File / Repo Mutation | No | No | No | Yes |
| Remote Artifact Mutation (Issues/Pages/Comments) | No (read-only viewing only) | Yes (issues/pages) | No (except issue comments) | Yes |
| Issue Commenting | No | Yes | Yes (issue comments only) | Yes |
| PR Create/Edit | No | Yes (no branch create/update) | No | Yes |
| PR Review (comments / batch) | No | Yes | Yes | Yes |
| PR Merge / Branch Ops | No | No | No | Yes |
| File | `copilot/modes/? Question.chatmode.md` | `copilot/modes/📚 Plan.chatmode.md` | `copilot/modes/📚 Review.chatmode.md` | `copilot/modes/🚀 Code.chatmode.md` |
| Contract Summary | Strict read-only (no mutations anywhere) | Mutate planning artifacts + create/edit/review PRs (no merge/branch ops) | PR review + issue comments only; no other mutations | Full implementation, execution, & PR lifecycle |
| Default Model | GPT-4.1 | Sonnet 4 | GPT-5 | Sonnet 4 |

Privilege gradient: Question < Review (adds review + issue comments) < Plan (adds planning artifact + PR creation/edit) < Code (full lifecycle incl. merge & branch ops).

## Tool Availability Matrix

Legend: ✅ available, ❌ unavailable in that mode.

| Tool | Question | Plan | Review | Code |
|------|-----|------|--------|------|
| **Built-In (VS Code / Core)** |||
| *Code & Project Navigation* |||
| [codebase](#codebase) | ✅ | ✅ | ✅ | ✅ |
| [findTestFiles](#findtestfiles) | ✅ | ✅ | ✅ | ✅ |
| [search](#search) | ✅ | ✅ | ✅ | ✅ |
| [searchResults](#searchresults) | ✅ | ✅ | ✅ | ✅ |
| [usages](#usages) | ✅ | ✅ | ✅ | ✅ |
| *Quality & Diagnostics* |||
| [problems](#problems) | ✅ | ✅ | ✅ | ✅ |
| [testFailure](#testfailure) | ✅ | ✅ | ✅ | ✅ |
| *Version Control & Changes* |||
| [changes](#changes) | ✅ | ✅ | ✅ | ✅ |
| *Environment & Execution* |||
| [terminalLastCommand](#terminallastcommand) | ✅ | ✅ | ✅ | ✅ |
| [terminalSelection](#terminalselection) | ❌ | ❌ | ❌ | ✅ |
| *Web & External Content* |||
| [fetch](#fetch) | ✅ | ✅ | ✅ | ✅ |
| [githubRepo](#githubrepo) | ✅ | ✅ | ✅ | ✅ |
| *Editor & Extensions* |||
| [extensions](#extensions) | ❌ | ❌ | ❌ | ❌ |
| [vscodeAPI](#vscodeapi) | ❌ | ❌ | ❌ | ❌ |
| *Editing & Automation* |||
| [editFiles](#editfiles) | ❌ | ❌ | ❌ | ✅ |
| [runCommands](#runcommands) | ❌ | ❌ | ❌ | ✅ |
| [runTasks](#runtasks) | ❌ | ❌ | ❌ | ✅ |
| *Pull Request Context* |||
| [activePullRequest](#activepullrequest) | ✅ | ✅ | ✅ | ✅ |
| **Context7** |||
| [resolve-library-id](#resolve-library-id) | ✅ | ✅ | ✅ | ✅ |
| [get-library-docs](#get-library-docs) | ✅ | ✅ | ✅ | ✅ |
| **Atlassian** |||
| *Jira Issues & Operations* |||
| [addCommentToJiraIssue](#addcommenttojiraissue) | ❌ | ✅ | ✅ | ✅ |
| [createJiraIssue](#createjiraissue) | ❌ | ✅ | ❌ | ✅ |
| [editJiraIssue](#editjiraissue) | ❌ | ✅ | ❌ | ✅ |
| [getJiraIssue](#getjiraissue) | ✅ | ✅ | ✅ | ✅ |
| [getJiraIssueRemoteIssueLinks](#getjiraissueremoteissuelinks) | ✅ | ✅ | ✅ | ✅ |
| [getTransitionsForJiraIssue](#gettransitionsforjiraissue) | ❌ | ❌ | ❌ | ❌ |
| [searchJiraIssuesUsingJql](#searchjiraissuesusingjql) | ✅ | ✅ | ✅ | ✅ |
| [transitionJiraIssue](#transitionjiraissue) | ❌ | ✅ | ❌ | ✅ |
| *Jira Project Metadata* |||
| [getJiraProjectIssueTypesMetadata](#getjiraprojectissuetypesmetadata) | ✅ | ✅ | ✅ | ✅ |
| [getVisibleJiraProjects](#getvisiblejiraprojects) | ✅ | ✅ | ✅ | ✅ |
| *Confluence Pages & Content* |||
| [createConfluencePage](#createconfluencepage) | ❌ | ✅ | ❌ | ✅ |
| [getConfluencePage](#getconfluencepage) | ✅ | ✅ | ✅ | ✅ |
| [getConfluencePageAncestors](#getconfluencepageancestors) | ❌ | ❌ | ❌ | ❌ |
| [getConfluencePageDescendants](#getconfluencepagedescendants) | ❌ | ❌ | ❌ | ❌ |
| [getPagesInConfluenceSpace](#getpagesinconfluencespace) | ✅ | ✅ | ✅ | ✅ |
| [updateConfluencePage](#updateconfluencepage) | ❌ | ✅ | ❌ | ✅ |
| *Confluence Comments* |||
| [createConfluenceFooterComment](#createconfluencefootercomment) | ❌ | ✅ | ❌ | ✅ |
| [createConfluenceInlineComment](#createconfluenceinlinecomment) | ❌ | ✅ | ❌ | ✅ |
| [getConfluencePageFooterComments](#getconfluencepagefootercomments) | ✅ | ✅ | ✅ | ✅ |
| [getConfluencePageInlineComments](#getconfluencepageinlinecomments) | ✅ | ✅ | ✅ | ✅ |
| *Confluence Spaces & Discovery* |||
| [getConfluenceSpaces](#getconfluencespaces) | ✅ | ✅ | ✅ | ✅ |
| [searchConfluenceUsingCql](#searchconfluenceusingcql) | ✅ | ✅ | ✅ | ✅ |
| *User & Identity* |||
| [atlassianUserInfo](#atlassianuserinfo) | ✅ | ✅ | ✅ | ✅ |
| [lookupJiraAccountId](#lookupjiraaccountid) | ✅ | ✅ | ✅ | ✅ |
| *Other* |||
| [getAccessibleAtlassianResources](#getaccessibleatlassianresources) | ✅ | ✅ | ✅ | ✅ |
| **GitHub** |||
| *Commits & Repository* |||
| [create_branch](#create_branch) | ❌ | ❌ | ❌ | ✅ |
| [create_repository](#create_repository) | ❌ | ❌ | ❌ | ✅ |
| [get_commit](#get_commit) | ✅ | ✅ | ✅ | ✅ |
| [get_file_contents](#get_file_contents) | ✅ | ✅ | ✅ | ✅ |
| [get_tag](#get_tag) | ❌ | ❌ | ❌ | ❌ |
| [list_branches](#list_branches) | ✅ | ✅ | ✅ | ✅ |
| [list_commits](#list_commits) | ✅ | ✅ | ✅ | ✅ |
| [list_tags](#list_tags) | ❌ | ❌ | ❌ | ❌ |
| [push_files](#push_files) | ❌ | ❌ | ❌ | ✅ |
| *Pull Requests – Retrieval* |||
| [activePullRequest](#activepullrequest) | ✅ | ✅ | ✅ | ✅ |
| [get_pull_request](#get_pull_request) | ✅ | ✅ | ✅ | ✅ |
| [get_pull_request_comments](#get_pull_request_comments) | ✅ | ✅ | ✅ | ✅ |
| [get_pull_request_diff](#get_pull_request_diff) | ✅ | ✅ | ✅ | ✅ |
| [get_pull_request_files](#get_pull_request_files) | ✅ | ✅ | ✅ | ✅ |
| [get_pull_request_reviews](#get_pull_request_reviews) | ✅ | ✅ | ✅ | ✅ |
| [get_pull_request_status](#get_pull_request_status) | ✅ | ✅ | ✅ | ✅ |
| [list_pull_requests](#list_pull_requests) | ✅ | ✅ | ✅ | ✅ |
| *Pull Requests – Actions* |||
| [add_comment_to_pending_review](#add_comment_to_pending_review) | ❌ | ✅ | ✅ | ✅ |
| [create_pending_pull_request_review](#create_pending_pull_request_review) | ❌ | ✅ | ✅ | ✅ |
| [create_pull_request](#create_pull_request) | ❌ | ✅ | ❌ | ✅ |
| [create_pull_request_with_copilot](#create_pull_request_with_copilot) | ❌ | ❌ | ❌ | ✅ |
| [merge_pull_request](#merge_pull_request) | ❌ | ❌ | ❌ | ✅ |
| [request_copilot_review](#request_copilot_review) | ❌ | ❌ | ❌ | ❌ |
| [submit_pending_pull_request_review](#submit_pending_pull_request_review) | ❌ | ✅ | ✅ | ✅ |
| [update_pull_request](#update_pull_request) | ❌ | ✅ | ❌ | ✅ |
| [update_pull_request_branch](#update_pull_request_branch) | ❌ | ❌ | ❌ | ✅ |
| *Sub-Issues* |||
| [list_sub_issues](#list_sub_issues) | ✅ | ✅ | ✅ | ✅ |
| [reprioritize_sub_issue](#reprioritize_sub_issue) | ❌ | ✅ | ❌ | ❌ |
| *Gists* |||
| [list_gists](#list_gists) | ❌ | ❌ | ❌ | ❌ |
| [update_gist](#update_gist) | ❌ | ❌ | ❌ | ❌ |
| *Notifications* |||
| [list_notifications](#list_notifications) | ✅ | ✅ | ✅ | ✅ |
| *Code Scanning & Security* |||
| [list_code_scanning_alerts](#list_code_scanning_alerts) | ❌ | ❌ | ❌ | ❌ |
| *Workflows (GitHub Actions)* |||
| [get_workflow_run](#get_workflow_run) | ✅ | ✅ | ❌ | ✅ |
| [get_workflow_run_logs](#get_workflow_run_logs) | ❌ | ❌ | ❌ | ❌ |
| [get_workflow_run_usage](#get_workflow_run_usage) | ❌ | ❌ | ❌ | ❌ |
| [list_workflow_jobs](#list_workflow_jobs) | ❌ | ❌ | ❌ | ❌ |
| [list_workflow_run_artifacts](#list_workflow_run_artifacts) | ✅ | ✅ | ❌ | ✅ |
| [list_workflow_runs](#list_workflow_runs) | ❌ | ❌ | ❌ | ❌ |
| [list_workflows](#list_workflows) | ❌ | ❌ | ❌ | ❌ |
| [rerun_failed_jobs](#rerun_failed_jobs) | ❌ | ❌ | ❌ | ❌ |
| [rerun_workflow_run](#rerun_workflow_run) | ❌ | ❌ | ❌ | ❌ |
| *Search & Discovery* |||
| [search_code](#search_code) | ✅ | ✅ | ✅ | ✅ |
| [search_orgs](#search_orgs) | ❌ | ❌ | ❌ | ❌ |
| [search_pull_requests](#search_pull_requests) | ✅ | ✅ | ✅ | ✅ |
| [search_repositories](#search_repositories) | ✅ | ✅ | ✅ | ✅ |
| [search_users](#search_users) | ❌ | ❌ | ❌ | ❌ |
| *User & Account* |||
| [get_me](#get_me) | ✅ | ✅ | ✅ | ✅ |
| *File Operations* |||
| [create_or_update_file](#create_or_update_file) | ❌ | ❌ | ❌ | ✅ |
## Notes
- Review mode adds PR review + issue commenting over Question, without broader planning artifact mutation.
- Plan mode extends Review with planning artifact creation/edit and PR creation/edit (no merge / branch ops).
- Code mode includes full repository mutation (branches, merges, execution) and remains only mode for merging and workflow reruns.

## Using `coding_guidelines.txt` Across Tools

### GitHub Copilot (Organization-Level)
1. Org admin navigates to GitHub: Settings > (Organization) > Copilot > Policies / Custom Instructions.
2. Open Custom Instructions editor and paste the full contents of `coding_guidelines.txt`.
3. Save; changes propagate to organization members (may require editor reload).
4. Version control: treat this repository file as the single source of truth; update here first, then re-paste.

### GitHub Copilot (Repository-Level)
1. Create or edit `.github/copilot-instructions.md`
2. Paste `coding_guidelines.txt` content.

### Warp (User-Level)
1. Open `Warp Drive` (the left sidebar) > `Rules` > `+ Add`
2. Paste `coding_guidelines.txt` content.

### Q (Repository-Level)
1. Create `.amazonq/rules/coding_guidelines.txt` in the repository root
2. Paste `coding_guidelines.txt` content.

### Claude Code (Repository-Level)
1. Create or edit `CLAUDE.md` in the repository root
2. Paste `coding_guidelines.txt` content.

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
#### Pull Request Context
##### activePullRequest
Retrieve context for the currently focused pull request.

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

## Notes
- Some tools appear in multiple conceptual groups; each tool has a dedicated anchor for direct linking.
- Question mode excludes all mutating / execution capabilities. Plan mode excludes code / repo / execution capabilities but permits planning artifact mutations. Code mode includes full capabilities.
- This document is the canonical source for tool availability; update table and definitions together.
