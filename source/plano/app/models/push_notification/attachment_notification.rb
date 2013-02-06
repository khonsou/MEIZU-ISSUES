class PushNotification::AttachmentNotification < PushNotification
  def self.notify(attachment, event_name = '')
    case event_name
    when 'upload'
      attachment.container.users.map do |user|
        unless user == User.current
          create(event_name: event_name, pusher: attachment, author: attachment.author, recipient: user)
        end
      end
    end
  end

  def project
    pusher.container
  end
end