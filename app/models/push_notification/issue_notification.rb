class PushNotification::IssueNotification < PushNotification
  def self.notify(issue, event_name = '')
    case event_name
    when 'create'
      issue.project.watch_users.map do |user|
        unless user == User.current
          create(event_name: event_name, pusher: issue, author: issue.author, recipient: user)
        end
      end
    end
  end

  def project
    pusher.project
  end
end