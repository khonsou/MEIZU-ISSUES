module Concerns
  module Mentionable
    extend ActiveSupport::Concern
    included do
      after_create :send_mention_notification
    end    
  
    def mentioned_users
      logins = self.notes.scan(/@(\w+|\p{Han}+)/u).flatten
      User.where("login in (?)", logins)
    end

    def send_mention_notification
      mentioned_users.each do |user|
        PushNotification::MentionNotification.notify(self)
      end
    end
  end
end
