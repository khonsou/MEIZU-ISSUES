class PushNotification::JournalDetailNotification < PushNotification
  def self.notify(journal_detail, event_name = '')
    journal_detail.journal.journalized.watcher_users.map do |user|
      unless user == User.current
        create(event_name: event_name, pusher: journal_detail, author: journal_detail.journal.user, recipient: user)
      end
    end
  end

  def project
    pusher.journal.issue.project
  end
end