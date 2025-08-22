# Atlassian MCP Tools Mapping

This table maps tools between the local Sooperset Atlassian MCP server and the official remote Atlassian MCP server.

| Local (Sooperset) | Remote (Official Atlassian) | Notes |
|-------------------|------------------------------|--------|
| **Jira Issues & Operations** | | |
| jira_add_comment | addCommentToJiraIssue | ✅ Direct mapping |
| jira_create_issue | createJiraIssue | ✅ Direct mapping |
| jira_update_issue | editJiraIssue | ✅ Direct mapping (note: "edit" vs "update") |
| jira_get_issue | getJiraIssue | ✅ Direct mapping |
| jira_search | searchJiraIssuesUsingJql | ✅ Direct mapping (JQL search) |
| jira_transition_issue | transitionJiraIssue | ✅ Direct mapping |
| jira_get_transitions | getTransitionsForJiraIssue | ✅ Direct mapping |
| jira_get_link_types | | ❌ Not available in remote |
| jira_get_project_versions | | ❌ Not available in remote |
| jira_get_worklog | | ❌ Not available in remote |
| jira_download_attachments | | ❌ Not available in remote |
| jira_add_worklog | | ❌ Not available in remote |
| jira_link_to_epic | | ❌ Not available in remote |
| jira_create_issue_link | | ❌ Not available in remote |
| jira_create_remote_issue_link | getJiraIssueRemoteIssueLinks | ⚠️ Read-only in remote (get vs create) |
| jira_delete_issue | | ❌ Not available in remote |
| **Jira Project & Board Operations** | | |
| jira_get_all_projects | getVisibleJiraProjects | ✅ Similar (visible vs all) |
| jira_get_project_issues | searchJiraIssuesUsingJql | ✅ Use JQL: `project = "KEY"` |
| jira_get_agile_boards | | ❌ Not available in remote |
| jira_get_board_issues | | ❌ Not available in remote |
| jira_get_sprints_from_board | | ❌ Not available in remote |
| jira_get_sprint_issues | | ❌ Not available in remote |
| jira_search_fields | getJiraProjectIssueTypesMetadata | ⚠️ Limited to issue type metadata |
| jira_get_user_profile | lookupJiraAccountId | ⚠️ Account lookup vs profile |
| **Confluence Pages & Content** | | |
| confluence_create_page | createConfluencePage | ✅ Direct mapping |
| confluence_get_page | getConfluencePage | ✅ Direct mapping |
| confluence_update_page | updateConfluencePage | ✅ Direct mapping |
| confluence_delete_page | | ❌ Not available in remote |
| confluence_get_page_children | getConfluencePageDescendants | ✅ Similar (children vs descendants) |
| confluence_search | searchConfluenceUsingCql | ✅ Direct mapping (CQL search) |
| confluence_get_comments | getConfluencePageFooterComments<br/>getConfluencePageInlineComments | ✅ Split into footer/inline comments |
| confluence_add_comment | createConfluenceFooterComment<br/>createConfluenceInlineComment | ✅ Split into footer/inline comments |
| confluence_get_labels | | ❌ Not available in remote |
| confluence_add_label | | ❌ Not available in remote |
| confluence_search_user | lookupJiraAccountId | ⚠️ Jira-only user lookup |
| **Remote-Only Tools** | | |
| | atlassianUserInfo | ➕ Get current user info |
| | getAccessibleAtlassianResources | ➕ Get cloud IDs for API calls |
| | getConfluenceSpaces | ➕ List/filter Confluence spaces |
| | getPagesInConfluenceSpace | ➕ List pages in a space |
| | getConfluencePageAncestors | ➕ Get page hierarchy (parents) |

## Summary

- **✅ Direct mappings:** 15 tools have direct or very close equivalents
- **⚠️ Partial mappings:** 5 tools have similar functionality with differences
- **❌ Local-only:** 13 tools are only available in the local server
- **➕ Remote-only:** 6 tools are only available in the remote server

## Key Differences

1. **Agile/Board Operations:** The remote server does not support Scrum/Kanban board operations (sprints, boards, etc.)
2. **Advanced Jira Features:** No support for worklogs, attachments, link types, or advanced linking
3. **Confluence Features:** No support for labels or advanced user operations
4. **Comment Types:** Remote server distinguishes between footer and inline comments
5. **User Management:** Remote focuses on account ID lookup rather than full profile data
6. **Space Management:** Remote server provides better space discovery and hierarchy navigation

## Migration Considerations

When switching between local and remote servers, tools that depend on board operations, worklogs, or advanced linking features will not be available in the remote server.
