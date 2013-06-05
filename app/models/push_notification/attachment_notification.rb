class PushNotification::AttachmentNotification < PushNotification
  def self.notify(attachment, event_name = '')
    case event_name
    when 'upload'
      users = case  attachment.container.class.name
      when 'Project'
         attachment.container.watch_users
      when 'Issue'
        attachment.container.should_notify_users          
      else
        []  
      end  
      users.map do |user|
        unless user == User.current
          create(event_name: event_name, pusher: attachment, author: attachment.author, recipient: user)
        end
      end
    end
  end

  def project
    container = pusher.container
    case  container.class.name
    when 'Project'
      pusher.container
    else
      Rails.logger.warn "container is of #{container.class.name}"
      raise "this is a temp code to find all the places this method is called wrongly" 
      
    end
  end
end
