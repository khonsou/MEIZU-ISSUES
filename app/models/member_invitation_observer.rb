class MemberInvitationObserver < ActiveRecord::Observer
  def after_create(member_invitation)
    Mailer.delay.member_invited(member_invitation)
  end
end
