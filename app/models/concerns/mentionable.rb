module Concerns
  module Mentionable
    extend ActiveSupport::Concern
    included do
      after_create :send_mention_notification
    end    
  
    def mentioned_users
      if self.notes.present?
        logins = self.notes.scan(/@(\w+|\p{Han}+)/u).flatten
                  
        self.project.member_principals.map(&:user).select do |user|
          logins.include?(user.name)
        end  
      else
        []
      end    
    end

    def send_mention_notification
      mentioned_users.each do |user|
        PushNotification::MentionNotification.notify(self)
      end
    end
  end
end
