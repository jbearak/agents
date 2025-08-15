# Manual analysis of tool differences

# Ask Mode tools (from lines 4-21):
ask_tools = {
    'codebase', 'usages', 'problems', 'changes', 'testFailure',
    'terminalLastCommand', 'fetch', 'findTestFiles', 'searchResults', 'githubRepo', 'search',
    'resolve-library-id', 'get-library-docs',
    'get_commit', 'get_file_contents', 'get_me',
    'get_pull_request', 'get_pull_request_comments', 'get_pull_request_diff',
    'get_pull_request_files', 'get_pull_request_reviews', 'get_pull_request_status', 'activePullRequest',
    'get_tag', 'list_branches', 'list_commits', 'list_tags', 'list_pull_requests',
    'list_code_scanning_alerts', 'list_notifications', 'list_gists', 'list_sub_issues',
    'get_workflow_run', 'get_workflow_run_logs', 'get_workflow_run_usage', 'list_workflow_jobs',
    'list_workflow_run_artifacts', 'list_workflow_runs', 'list_workflows', 'search_code',
    'search_orgs', 'search_pull_requests', 'search_repositories', 'search_users',
    'getJiraIssue', 'getJiraIssueRemoteIssueLinks', 'searchJiraIssuesUsingJql',
    'getJiraProjectIssueTypesMetadata', 'getVisibleJiraProjects',
    'getConfluencePage', 'getConfluencePageAncestors', 'getConfluencePageDescendants',
    'getPagesInConfluenceSpace', 'getConfluencePageFooterComments', 'getConfluencePageInlineComments',
    'getConfluenceSpaces', 'searchConfluenceUsingCql', 'atlassianUserInfo', 'lookupJiraAccountId',
    'getAccessibleAtlassianResources'
}

# Plan Mode tools (from lines 5-22):
plan_tools = {
    'codebase', 'usages', 'problems', 'changes', 'testFailure',
    'terminalLastCommand', 'fetch', 'findTestFiles', 'searchResults', 'githubRepo', 'search',
    'resolve-library-id', 'get-library-docs',
    'get_commit', 'get_file_contents', 'get_me',
    'get_pull_request', 'get_pull_request_comments', 'get_pull_request_diff',
    'get_pull_request_files', 'get_pull_request_reviews', 'get_pull_request_status', 'activePullRequest',
    'create_pull_request', 'update_pull_request', 'create_pending_pull_request_review',
    'add_comment_to_pending_review', 'submit_pending_pull_request_review', 'request_copilot_review',
    'get_tag', 'list_branches', 'list_commits', 'list_tags', 'list_pull_requests',
    'list_code_scanning_alerts', 'list_notifications', 'list_gists', 'list_sub_issues',
    'reprioritize_sub_issue', 'get_workflow_run', 'get_workflow_run_logs', 'get_workflow_run_usage',
    'list_workflow_jobs', 'list_workflow_run_artifacts', 'list_workflow_runs', 'list_workflows',
    'search_code', 'search_orgs', 'search_pull_requests', 'search_repositories', 'search_users',
    'addCommentToJiraIssue', 'createJiraIssue', 'editJiraIssue', 'getJiraIssue',
    'getJiraIssueRemoteIssueLinks', 'getTransitionsForJiraIssue', 'searchJiraIssuesUsingJql', 'transitionJiraIssue',
    'getJiraProjectIssueTypesMetadata', 'getVisibleJiraProjects',
    'createConfluencePage', 'getConfluencePage', 'getConfluencePageAncestors', 'getConfluencePageDescendants',
    'getPagesInConfluenceSpace', 'updateConfluencePage', 'createConfluenceFooterComment',
    'createConfluenceInlineComment', 'getConfluencePageFooterComments', 'getConfluencePageInlineComments',
    'getConfluenceSpaces', 'searchConfluenceUsingCql', 'atlassianUserInfo', 'lookupJiraAccountId',
    'getAccessibleAtlassianResources'
}

# Review Mode tools (from lines 5-13):
review_tools = {
    'codebase', 'usages', 'problems', 'changes', 'testFailure', 'terminalLastCommand',
    'fetch', 'findTestFiles', 'searchResults', 'githubRepo', 'search',
    'resolve-library-id', 'get-library-docs',
    'get_commit', 'get_file_contents', 'get_me', 'list_branches', 'list_commits', 'list_tags',
    'get_pull_request', 'get_pull_request_comments', 'get_pull_request_diff',
    'get_pull_request_files', 'get_pull_request_reviews', 'get_pull_request_status', 'list_pull_requests', 'activePullRequest',
    'add_comment_to_pending_review', 'create_pending_pull_request_review', 'submit_pending_pull_request_review', 'request_copilot_review',
    'list_notifications', 'search_code', 'search_pull_requests', 'search_repositories', 'search_users', 'search_orgs', 'list_sub_issues',
    'addCommentToJiraIssue', 'getJiraIssue', 'getJiraIssueRemoteIssueLinks', 'searchJiraIssuesUsingJql', 'getJiraProjectIssueTypesMetadata', 'getVisibleJiraProjects',
    'getConfluencePage', 'getConfluencePageAncestors', 'getConfluencePageDescendants', 'getPagesInConfluenceSpace',
    'getConfluencePageFooterComments', 'getConfluencePageInlineComments', 'getConfluenceSpaces', 'searchConfluenceUsingCql',
    'atlassianUserInfo', 'lookupJiraAccountId', 'getAccessibleAtlassianResources'
}

# Code Mode tools (from lines 4-16):
code_tools = {
    'codebase', 'usages', 'problems', 'changes', 'testFailure', 'terminalSelection', 'terminalLastCommand',
    'fetch', 'findTestFiles', 'searchResults', 'githubRepo', 'search',
    'editFiles', 'runCommands', 'runTasks', 'create_or_update_file',
    'add_comment_to_pending_review', 'create_pending_pull_request_review', 'submit_pending_pull_request_review', 'request_copilot_review',
    'create_pull_request', 'update_pull_request', 'merge_pull_request', 'update_pull_request_branch', 'create_pull_request_with_copilot',
    'create_branch', 'push_files', 'create_repository', 'reprioritize_sub_issue',
    'get_commit', 'get_file_contents', 'get_me', 'get_pull_request', 'get_pull_request_comments', 'get_pull_request_diff', 'get_pull_request_files', 'get_pull_request_reviews', 'get_pull_request_status', 'activePullRequest',
    'get_tag', 'list_branches', 'list_commits', 'list_tags', 'list_pull_requests', 'list_code_scanning_alerts', 'list_notifications', 'list_gists', 'list_sub_issues',
    'get_workflow_run', 'get_workflow_run_logs', 'get_workflow_run_usage', 'list_workflow_jobs', 'list_workflow_run_artifacts', 'list_workflow_runs', 'list_workflows', 'rerun_failed_jobs', 'rerun_workflow_run',
    'search_code', 'search_orgs', 'search_pull_requests', 'search_repositories', 'search_users',
    'resolve-library-id', 'get-library-docs',
    'addCommentToJiraIssue', 'createJiraIssue', 'editJiraIssue', 'getJiraIssue', 'getJiraIssueRemoteIssueLinks', 'getTransitionsForJiraIssue', 'searchJiraIssuesUsingJql', 'transitionJiraIssue',
    'getJiraProjectIssueTypesMetadata', 'getVisibleJiraProjects', 'createConfluencePage', 'getConfluencePage', 'getConfluencePageAncestors', 'getConfluencePageDescendants', 'getPagesInConfluenceSpace', 'updateConfluencePage',
    'createConfluenceFooterComment', 'createConfluenceInlineComment', 'getConfluencePageFooterComments', 'getConfluencePageInlineComments', 'getConfluenceSpaces', 'searchConfluenceUsingCql',
    'atlassianUserInfo', 'lookupJiraAccountId', 'getAccessibleAtlassianResources'
}

print(f'Ask tools count: {len(ask_tools)}')
print(f'Plan tools count: {len(plan_tools)}')  
print(f'Review tools count: {len(review_tools)}')
print(f'Code tools count: {len(code_tools)}')

print('\n=== TOOLS IN PLAN BUT NOT IN CODE ===')
plan_not_code = plan_tools - code_tools
for tool in sorted(plan_not_code):
    print(f'  {tool}')
print(f'Count: {len(plan_not_code)}')

print('\n=== TOOLS IN REVIEW BUT NOT IN CODE ===')
review_not_code = review_tools - code_tools
for tool in sorted(review_not_code):
    print(f'  {tool}')
print(f'Count: {len(review_not_code)}')

print('\n=== TOOLS IN BOTH PLAN AND REVIEW BUT NOT IN CODE ===')
both_not_code = (plan_tools & review_tools) - code_tools
for tool in sorted(both_not_code):
    print(f'  {tool}')
print(f'Count: {len(both_not_code)}')

print('\n=== ALL MISSING TOOLS FROM CODE ===')
all_missing = (plan_tools | review_tools) - code_tools
for tool in sorted(all_missing):
    print(f'  {tool}')
print(f'Count: {len(all_missing)}')
