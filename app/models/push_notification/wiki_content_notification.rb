class PushNotification::WikiContentNotification < PushNotification
  def self.notify(wiki_content, event_name = '')
    case event_name
    when 'create'
      wiki_content.project.watch_users.map do |user|
        unless user == User.current
          create(event_name: event_name, pusher: wiki_content, author: wiki_content.author, recipient: user)
        end
      end
    when 'update'
      wiki_content.project.watch_users.map do |user|
        unless user == User.current
          create(event_name: event_name, pusher: wiki_content, author: wiki_content.author, recipient: user)
        end
      end
    end
  end

  def project
    pusher.page.project
  end

  def page
    pusher.page
  end

  def wiki
    pusher.page.wiki
  end
end