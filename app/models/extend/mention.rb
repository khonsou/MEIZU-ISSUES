module Extend
  module Mentionable
    extend ActiveSupport::Concern
    included do
      before_save :extract_mentioned_users
      after_create :send_mention_notification
      has_many :notification_mentions, :as => :mentionable, :class_name => 'Notification::Mention'

      attr_accessor :notified_user_ids
      after_initialize do 
        self.notified_user_ids = []
      end
    end    

    def mentioned_users
      logins = body.scan(/@(\w{3,20})/).flatten
      User.where(:login => /^(#{logins.join('|')})$/i).limit(5)
    end

    def send_mention_notification
      mentioned_users.each do |user|
        self.notified_user_ids << user.id
        Notification::Mention.create :user => user, :mentionable => self
      end
    end
  end
end
