class PushNotificationsController < ApplicationController
  def index
    @limit = params[:limit].try(:to_i) || 20
    @push_notifications = User.current.push_notifications
    @max_limit = @push_notifications.count
    @push_notifications = @push_notifications.limit(@limit)
  end

  def popover
    @unread_count = User.current.push_notifications.unread.count
    @push_notifications = User.current.push_notifications.unread.limit(9)
  end

  def read
    @push_notification = User.current.push_notifications.find(params[:id])
    @push_notification.mark_as_read

    redirect_to params[:pusher_path]
  end

  def mark_as_read
    @push_notification = User.current.push_notifications.find(params[:id])
    @push_notification.mark_as_read
  end
  
  def mark_popover_as_read
    push_notifications = User.current.push_notifications.unread.limit(9)
    push_notifications.each do |push_notification|
      push_notification.mark_as_read
    end
    @unread_count = User.current.push_notifications.unread.count
    @push_notifications = User.current.push_notifications.unread.limit(9)
  end

  def mark_all_as_read
    PushNotification.mark_all_as_read(User.current)

    redirect_to push_notifications_path
  end
end
