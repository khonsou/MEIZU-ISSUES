class PushNotification::MentionNotification < PushNotification
  def self.notify(object, event_name = '')
    object.mentioned_users.map do |user|
      unless user == User.current
        create(event_name: event_name, pusher: object, author: object.user, recipient: user)
      end
    end
  end

  def project
    pusher.project
  end
end
