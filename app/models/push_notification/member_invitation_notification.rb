class PushNotification::MemberInvitationNotification < PushNotification
  def self.notify(member_invitation, event_name = '')
    case event_name
    when 'create'
      if member_invitation.user
        create(event_name: event_name, pusher: member_invitation, author: member_invitation.inviter, recipient: member_invitation.user)
      end
    end
  end

  def project
    pusher.project
  end
end
