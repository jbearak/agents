# Ask Mode Tools Reference

This document centralizes tool descriptions removed from the `tools` array (JSONC comments are disallowed). Tools are grouped by their MCP server or source, then thematically.

## Built-In (VS Code)

### Code & Project Navigation
- `codebase` – Search, read, and analyze project source code
- `usages` – Find references, definitions, and other usages of a symbol
- `search` – Search and read files in your workspace
- `searchResults` – Access the results from the search view
- `findTestFiles` – For a source code file, find the file that contains the tests; for a test file, find the file containing the code under test

### Quality & Diagnostics
- `problems` – Check errors for a particular file
- `testFailure` – Includes information about the last unit test failure

### Version Control & Changes
- `changes` – Get diffs of changed files

### Environment & Execution
- `terminalLastCommand` – The active terminal's last run command

### Web & External Content
- `fetch` – Fetch the main content from a web page (include the URL)
- `githubRepo` – Searches a GitHub repository for relevant source code snippets

### Pull Request Context (Extension)
- `activePullRequest` – Get information about the active GitHub pull request (GitHub Pull Requests extension)

##  Context7 MCP Server
Access library documentation and examples (wrapper name)

- `get-library-docs` – Fetches up-to-date documentation for a library (call `resolve-library-id` first unless ID provided)
- `resolve-library-id` – Resolves a package/product name to a Context7-compatible library ID

## Atlassian Remote MCP Server

### Jira Issues & Operations
- `createJiraIssue` – Create a new Jira issue in a given project
- `editJiraIssue` – Update the details of an existing Jira issue id or key
- `getJiraIssue` – Get the details of a Jira issue by issue id or key
- `transitionJiraIssue` – Transition an existing Jira issue to a new status
- `addCommentToJiraIssue` – Adds a comment to an existing Jira issue id or key
- `getTransitionsForJiraIssue` – Get available transitions for an existing Jira issue id or key
- `getJiraIssueRemoteIssueLinks` – Get remote issue links (e.g., Confluence links, etc.) of a Jira issue
- `searchJiraIssuesUsingJql` – Search Jira issues using Jira Query Language (JQL)

### Jira Project Metadata
- `getVisibleJiraProjects` – Get visible Jira projects the user can access
- `getJiraProjectIssueTypesMetadata` – Get a page of issue type metadata for a specified project

### Confluence Pages & Content
- `createConfluencePage` – Create a new page in Confluence (regular or live doc)
- `updateConfluencePage` – Update an existing page or live doc in Confluence
- `getConfluencePage` – Get a specific page or live doc data (including body content)
- `getPagesInConfluenceSpace` – Get all pages within a specific Confluence space
- `getConfluencePageAncestors` – Get all parent pages (ancestors) of a page
- `getConfluencePageDescendants` – Get all child pages (descendants) of a page

### Confluence Comments
- `createConfluenceFooterComment` – Create a footer comment on a Confluence page or blog post
- `createConfluenceInlineComment` – Create an inline comment on a page or blog post
- `getConfluencePageFooterComments` – Get footer comments for a Confluence page
- `getConfluencePageInlineComments` – Get inline comments for a Confluence page

### Confluence Spaces & Discovery
- `getConfluenceSpaces` – Get spaces from Confluence
- `searchConfluenceUsingCql` – Search content in Confluence using CQL

### User & Identity
- `atlassianUserInfo` – Get current user info from Atlassian
- `lookupJiraAccountId` – Lookup account ids of existing users in Jira

### Other
- `getAccessibleAtlassianResources` - Get cloudid to construct API calls to Atlassian REST APIs


## GitHub Remote MCP Server

### Commits & Repository
- `get_commit` – Get details for a commit from a GitHub repository
- `get_file_contents` – Get the contents of a file or directory from a GitHub repository
- `list_branches` – List branches in a GitHub repository
- `list_commits` – Get list of commits of a branch
- `get_tag` – Get details about a specific git tag
- `list_tags` – List git tags in a GitHub repository
- `create_repository` – Create a new GitHub repository in your account
- `create_branch` – Create a new branch in a GitHub repository
- `push_files` – Push multiple files to a GitHub repository in a single commit

### Pull Requests – Retrieval
- `get_pull_request` – Get details of a specific pull request
- `get_pull_request_comments` – Get comments for a specific pull request
- `get_pull_request_diff` – Get the diff of a pull request
- `get_pull_request_files` – Get the files changed in a pull request
- `get_pull_request_reviews` – Get reviews for a specific pull request
- `get_pull_request_status` – Get the status of a specific pull request

### Pull Requests – Actions
- `create_pull_request` – Create a new pull request
- `update_pull_request` – Update an existing pull request
- `update_pull_request_branch` – Update the branch of a pull request with latest changes
- `merge_pull_request` – Merge a pull request
- `create_pending_pull_request_review` – Create a pending pull request review
- `add_comment_to_pending_review` – Add review comment to the requester's latest pending review
- `submit_pending_pull_request_review` – Submit the requester's latest pending pull request review
- `request_copilot_review` – Request a GitHub Copilot code review for a pull request
- `create_pull_request_with_copilot` – Delegate a task to GitHub Copilot coding agent to perform in the background (creates PR)

### Issues & Discussions
- list_issues – List issues in a GitHub repository
- get_issue – Get details of a specific issue
- get_issue_comments – Get comments for a specific issue
- add_issue_comment – Add a comment to a specific issue
- create_issue – Create a new issue in a GitHub repository
- update_issue – Update an existing issue in a GitHub repository
- list_discussion_categories – List discussion categories for a repository or organization
- list_discussions – List discussions for a repository or organization
- get_discussion – Get a specific discussion by ID
- get_discussion_comments – Get comments from a discussion

### Sub-Issues
- add_sub_issue – Add a sub-issue to a parent issue
- remove_sub_issue – Remove a sub-issue from a parent issue
- reprioritize_sub_issue – Reprioritize a sub-issue to a different position
- list_sub_issues – List sub-issues for a specific issue

### Gists
- create_gist – Create a new gist
- update_gist – Update an existing gist
- list_gists – List gists for a user

### Notifications
- list_notifications – Lists all GitHub notifications for the authenticated user
- mark_all_notifications_read – Mark all notifications as read
- manage_notification_subscription – Manage a notification subscription
- manage_repository_notification_subscription – Manage a repository notification subscription
- get_notification_details – Get detailed information for a specific GitHub notification

### Code Scanning & Security
- list_code_scanning_alerts – List code scanning alerts in a GitHub repository
- get_dependabot_alert – Get details of a specific dependabot alert
- list_dependabot_alerts – List dependabot alerts
- list_secret_scanning_alerts – List secret scanning alerts
- get_secret_scanning_alert – Get details of a specific secret scanning alert
- get_dependabot_alert – Get details of a specific dependabot alert

### Workflows (GitHub Actions)
- get_workflow_run – Get details of a specific workflow run
- get_workflow_run_logs – Download logs for a specific workflow run
- get_workflow_run_usage – Get usage metrics for a workflow run
- list_workflow_runs – List workflow runs with filters
- list_workflows – List workflows in a repository
- list_workflow_jobs – List jobs for a specific workflow run
- list_workflow_run_artifacts – List artifacts for a workflow run
- rerun_failed_jobs – Re-run only the failed jobs in a workflow run
- rerun_workflow_run – Re-run an entire workflow run
- run_workflow – Run an Actions workflow by workflow ID or filename
- get_job_logs – Download logs for a specific workflow job or failed job logs

### Search & Discovery
- search_code – Fast and precise code search across all GitHub repositories
- search_pull_requests – Search for pull requests in GitHub repositories
- search_repositories – Find GitHub repositories by name, description, readme, topics
- search_users – Find GitHub users by username, real name, or other profile info
- search_orgs – Find GitHub organizations by name, location, or other metadata
- search_issues – Search for issues in GitHub repositories

### User & Account
- get_me – Get details of the authenticated GitHub user

### Advanced / Misc
- activePullRequest – (Also exposed via extension category) active PR context

## Notes
- Some tools appear in multiple conceptual groups (e.g., `activePullRequest`). They are listed where most relevant.
- Only read-only tools should be enabled in Ask Mode per mode instructions; destructive or mutating GitHub tools are documented but may remain disabled in configuration.
