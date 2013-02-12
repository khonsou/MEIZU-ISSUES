# Redmine - project management software
# Copyright (C) 2006-2012  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

module Redmine
  module DefaultData
    class DataAlreadyLoaded < Exception; end

    module Loader
      include Redmine::I18n

      class << self
        # Returns true if no data is already loaded in the database
        # otherwise false
        def no_data?
          !Role.find(:first, :conditions => {:builtin => 0}) &&
            !Tracker.find(:first) &&
            !IssueStatus.find(:first) &&
            !Enumeration.find(:first)
        end

        # Loads the default data
        # Raises a RecordNotSaved exception if something goes wrong
        def load(lang=nil)
          raise DataAlreadyLoaded.new("Some configuration data is already loaded.") unless no_data?
          set_language_if_valid(lang)

          Role.transaction do
            # Roles
            member = Role.create! :name => l(:default_role_member),
                                   :issues_visibility => 'all',
                                   :position => 1
            member.permissions = member.setable_permissions.collect {|p| p.name}
            member.save!

            Role.non_member.update_attribute :permissions, [:add_project,
                                                            :view_issues,
                                                            :add_issues,
                                                            :add_issue_notes,
                                                            :save_queries,
                                                            :view_gantt,
                                                            :view_calendar,
                                                            :view_time_entries,
                                                            :comment_news,
                                                            :view_documents,
                                                            :view_wiki_pages,
                                                            :view_wiki_edits,
                                                            :add_messages,
                                                            :view_files,
                                                            :browse_repository,
                                                            :view_changesets]

            Role.anonymous.update_attribute :permissions, [:add_project,
                                                           :view_issues,
                                                           :view_gantt,
                                                           :view_calendar,
                                                           :view_time_entries,
                                                           :view_documents,
                                                           :view_wiki_pages,
                                                           :view_wiki_edits,
                                                           :view_files,
                                                           :browse_repository,
                                                           :view_changesets]

            # Trackers
            Tracker.create!(:name => l(:default_tracker_default),     :is_in_chlog => false,  :is_in_roadmap => false, :position => 1)

            # Issue statuses
            new       = IssueStatus.create!(:name => l(:default_issue_status_new), :is_closed => false, :is_default => true, :position => 1)
            closed    = IssueStatus.create!(:name => l(:default_issue_status_closed), :is_closed => true, :is_default => false, :position => 5)

            # Workflow
            Tracker.find(:all).each { |t|
              IssueStatus.find(:all).each { |os|
                IssueStatus.find(:all).each { |ns|
                  WorkflowTransition.create!(:tracker_id => t.id, :role_id => member.id, :old_status_id => os.id, :new_status_id => ns.id) unless os == ns
                }
              }
            }

            # Enumerations
            IssuePriority.create!(:name => l(:default_priority_normal), :position => 1, :is_default => true)
          end
          true
        end
      end
    end
  end
end
