class PushNotificationsController < ApplicationController
  def index
    @limit = params[:limit].try(:to_i) || 20
    @push_notifications = User.current.push_notifications
    @max_limit = @push_notifications.count
    @push_notifications = @push_notifications.limit(@limit)
  end

  def popover
    pending_members_push_notifications_and_unread_count
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
    pending_members_push_notifications_and_unread_count
    if @pending_members.size > 10
      push_notification_member_pending = 10
    else
      pending_members_count = @pending_members.size
    end
    push_notifications = User.current.push_notifications.unread.limit(10 - pending_members_count)
    push_notifications.each do |push_notification|
      push_notification.mark_as_read
    end
    @push_notifications = User.current.push_notifications.where("pusher_type != 'MemberInvitation'").unread
    @unread_count = @push_notifications.count + @pending_members.size
  end

  def mark_all_as_read
    PushNotification.mark_all_as_read(User.current)

    redirect_to push_notifications_path
  end
  
  private

  def pending_members_push_notifications_and_unread_count
    member_invitations = User.current.member_invitations.where("state = 'pending'")\
     - User.current.member_invitations.where(:project_id => User.current.members.map{|p| p.project_id})
    @push_notifications = User.current.push_notifications.where("pusher_type != 'MemberInvitation'").unread
    @pending_members = member_invitations.map{|p| p.push_notifications}.reverse.flatten
    @unread_count = @push_notifications.count + @pending_members.size
  end
end
