Role.create(name: "Manager", builtin: 0, issues_visibility: "all", permissions: [:add_project, :edit_project, :close_project, :select_project_modules, :manage_members, :manage_versions, :add_subprojects, :manage_categories, :view_issues, :add_issues, :edit_issues, :manage_issue_relations, :manage_subtasks, :set_issues_private, :set_own_issues_private, :add_issue_notes, :edit_issue_notes, :edit_own_issue_notes, :move_issues, :delete_issues, :manage_public_queries, :save_queries, :view_issue_watchers, :add_issue_watchers, :delete_issue_watchers, :log_time, :view_time_entries, :edit_time_entries, :edit_own_time_entries, :manage_project_activities, :manage_news, :comment_news, :manage_documents, :view_documents, :manage_files, :view_files, :view_attachments, :manage_wiki, :rename_wiki_pages, :delete_wiki_pages, :view_wiki_pages, :export_wiki_pages, :view_wiki_edits, :edit_wiki_pages, :delete_wiki_pages_attachments, :protect_wiki_pages, :manage_repository, :browse_repository, :view_changesets, :commit_access, :manage_related_issues, :manage_boards, :add_messages, :edit_messages, :edit_own_messages, :delete_messages, :delete_own_messages, :view_calendar, :view_gantt, :manage_member_invitations] )

IssueStatus.create(name: "New", is_default: true, is_closed: false)
IssueStatus.create(name: "Assigned", is_default: false, is_closed: false)
IssueStatus.create(name: "Resolved", is_default: false, is_closed: false)
IssueStatus.create(name: "Feedback", is_default: false, is_closed: false)
IssueStatus.create(name: "Closed", is_default: false, is_closed: true)
IssueStatus.create(name: "Rejected", is_default: false, is_closed: true)

IssuePriority.create(name: "normal", is_default: true, active: true)
IssuePriority.create(name: "big", is_default: false, active: true)

Tracker.create(name: "Bug", is_in_chlog: true)
Tracker.create(name: "Feature request", is_in_chlog: true)
Tracker.create(name: "Support request", is_in_chlog: false)
