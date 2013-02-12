class PushNotification < ActiveRecord::Base
  belongs_to :pusher, polymorphic: true
  belongs_to :author, class_name: 'User'
  belongs_to :recipient, class_name: 'User'

  default_scope order: "#{self.table_name}.created_at DESC"
  scope :unread, lambda { where("#{table_name}.read IS FALSE OR #{table_name}.read IS NULL") }

  def read?
    !!read
  end

  def unread?
    !read
  end

  def mark_as_read(user = nil)
    if user.blank?
      update_attributes(read: true) if unread?
    else
      update_attributes(read: true) if unread? && self.recipient == user
    end
  end

  def self.mark_all_as_read(user)
    user.push_notifications.unread.each do |push_notification|
      push_notification.mark_as_read
    end
  end
end

Dir["#{File.dirname(__FILE__)}/#{File.basename(__FILE__, '.*')}/**/*.rb"].each { |f| require_dependency f }

class PushNotification
  def underscore
    self.class.name.underscore
  end
end
