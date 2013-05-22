# encoding: utf-8

module PushNotificationsHelper
  def get_pusher_path(push_notification)
    case push_notification.pusher.container_type
    when 'Project'
      project_files_path(project_id: push_notification.pusher.container.id, anchor: dom_id(push_notification.pusher))
    when 'Issue'
      issue_path(push_notification.pusher.container.id, anchor: dom_id(push_notification.pusher))
    else 
      raise "push_notification pusher container type #{push_notification.pusher.container_type} is used in get_pusher_path"
    end
  end

  def link_to_pusher_container(push_notification)
    case push_notification.pusher.container_type
    when 'Project'
      link_to_project(push_notification.pusher.container)
    when 'Issue'
      link_to_issue(push_notification.pusher.container)
    else 
      raise "push_notification pusher container type #{push_notification.pusher.container_type} is used in link_to_pusher_container"
    end
  end
end
