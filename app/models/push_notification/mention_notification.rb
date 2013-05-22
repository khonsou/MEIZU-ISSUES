class PushNotification::MentionNotification < PushNotification
  def self.notify(journal, event_name = '')
    journal.mentioned_users.map do |user|
      unless user == User.current
        create(event_name: event_name, pusher: journal, author: journal.user, recipient: user)
      end
    end
  end

  def project
    pusher.issue.project
  end
end
