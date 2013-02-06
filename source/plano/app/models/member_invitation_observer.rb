class MemberInvitationObserver < ActiveRecord::Observer
  def after_create(member_invitation)
    Mailer.member_invited(member_invitation).deliver
  end
end
