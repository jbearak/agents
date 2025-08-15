# Tools that should be in Code mode based on README matrix

tools_that_should_be_in_code = [
    # Built-in tools
    'codebase', 'findTestFiles', 'search', 'searchResults', 'usages',
    'problems', 'testFailure', 'changes', 'terminalLastCommand', 'terminalSelection',
    'fetch', 'githubRepo', 'editFiles', 'runCommands', 'runTasks', 'activePullRequest',
    
    # Context7
    'resolve-library-id', 'get-library-docs',
    
    # Atlassian - all marked as ✅ for Code mode in README
    'addCommentToJiraIssue', 'createJiraIssue', 'editJiraIssue', 'getJiraIssue',
    'getJiraIssueRemoteIssueLinks', 'getTransitionsForJiraIssue', 'searchJiraIssuesUsingJql',
    'transitionJiraIssue', 'getJiraProjectIssueTypesMetadata', 'getVisibleJiraProjects',
    'createConfluencePage', 'getConfluencePage', 'getConfluencePageAncestors',
    'getConfluencePageDescendants', 'getPagesInConfluenceSpace', 'updateConfluencePage',
    'createConfluenceFooterComment', 'createConfluenceInlineComment',
    'getConfluencePageFooterComments', 'getConfluencePageInlineComments',
    'getConfluenceSpaces', 'searchConfluenceUsingCql', 'atlassianUserInfo',
    'lookupJiraAccountId', 'getAccessibleAtlassianResources',
    
    # GitHub - all marked as ✅ for Code mode
    'create_branch', 'create_repository', 'get_commit', 'get_file_contents',
    'get_tag', 'list_branches', 'list_commits', 'list_tags', 'push_files',
    'activePullRequest', 'get_pull_request', 'get_pull_request_comments',
    'get_pull_request_diff', 'get_pull_request_files', 'get_pull_request_reviews',
    'get_pull_request_status', 'list_pull_requests', 'add_comment_to_pending_review',
    'create_pending_pull_request_review', 'create_pull_request',
    'create_pull_request_with_copilot', 'merge_pull_request', 'request_copilot_review',
    'submit_pending_pull_request_review', 'update_pull_request',
    'update_pull_request_branch', 'list_sub_issues', 'reprioritize_sub_issue',
    'list_gists', 'update_gist', 'list_notifications', 'list_code_scanning_alerts',
    'get_workflow_run', 'get_workflow_run_logs', 'get_workflow_run_usage',
    'list_workflow_jobs', 'list_workflow_run_artifacts', 'list_workflow_runs',
    'list_workflows', 'rerun_failed_jobs', 'rerun_workflow_run',
    'search_code', 'search_orgs', 'search_pull_requests', 'search_repositories',
    'search_users'
]

# Check which are missing from Code.chatmode.md by reading the file
with open('copilot/modes/Code.chatmode.md', 'r') as f:
    code_content = f.read()

# Extract tools from Code.chatmode.md
import re
tools_match = re.search(r'tools:\s*\[(.*?)\]', code_content, re.DOTALL)
if tools_match:
    tools_str = tools_match.group(1)
    actual_tools = [tool.strip().strip("'\"") for tool in tools_str.split(',') if tool.strip()]
    actual_tools_set = set(actual_tools)
else:
    actual_tools_set = set()

print(f"Tools that should be in Code mode: {len(tools_that_should_be_in_code)}")
print(f"Tools actually in Code mode: {len(actual_tools_set)}")

missing_tools = set(tools_that_should_be_in_code) - actual_tools_set
print(f"\nMissing tools from Code mode ({len(missing_tools)}):")
for tool in sorted(missing_tools):
    print(f"  {tool}")

# Also check for extra tools in Code mode that aren't in our expected list
extra_tools = actual_tools_set - set(tools_that_should_be_in_code)
print(f"\nExtra tools in Code mode not in README list ({len(extra_tools)}):")
for tool in sorted(extra_tools):
    print(f"  {tool}")
