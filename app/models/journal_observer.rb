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

class JournalObserver < ActiveRecord::Observer
  def after_create(journal)
    unless journal.issue.watched_by?(journal.user)
      journal.issue.add_watcher(journal.user)
    end

    if journal.journalized.is_a?(Issue)
      if journal.details.blank?
        if !journal.notes.blank?
          PushNotification::JournalNotification.notify(journal, 'comment')
        end
      else
        journal.details.each do |detail|
          case detail.prop_key
          when 'due_date'
            unless detail.value.blank?
              PushNotification::JournalDetailNotification.notify(detail, 'add_due_date')
            else
              PushNotification::JournalDetailNotification.notify(detail, 'remove_due_date')
            end
          when 'assigned_to_id'
            unless detail.value.blank?
              begin
                assignee = User.find(detail.value)
                unless journal.issue.watched_by?(assignee)
                  journal.issue.add_watcher(assignee)
                end
              rescue
              end

              PushNotification::JournalDetailNotification.notify(detail, 'add_assignee')
            else
              PushNotification::JournalDetailNotification.notify(detail, 'remove_assignee')
            end
          when 'status_id'
            if IssueStatus.find(detail.value).is_closed?
              PushNotification::JournalDetailNotification.notify(detail, 'close')
            else
              PushNotification::JournalDetailNotification.notify(detail, 'reopen')
            end
          when 'description'
            PushNotification::JournalDetailNotification.notify(detail, 'description')
          else
            PushNotification::JournalDetailNotification.notify(detail, 'update')
          end
        end
      end
    end

    Mailer.delay.issue_edit(journal)
  end
end
