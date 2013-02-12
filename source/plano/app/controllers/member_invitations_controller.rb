class MemberInvitationsController < ApplicationController
  before_filter :find_optional_project, :only => [:new, :create]

  def new
    @all_recipients = User.status(User::STATUS_ACTIVE)
    @recipients = []
    if params[:user_id]
      user = User.find(params[:user_id])
      @recipients << user
    end
  end

  def create
    mails = params[:recipients].split(',').map { |m| User.parse_mail(m) }.compact.uniq
    member_invitations = MemberInvitation.invite(@project, mails, params[:description])
  end

  def show
    @member_invitation = MemberInvitation.find(params[:id])

    if @member_invitation.user == User.current || @member_invitation.mail == User.current.mail
      @member_invitation.push_notifications.each { |pn| pn.mark_as_read(User.current) }

      if @member_invitation.accepted?
        redirect_to project_path(@member_invitation.project), notice: l(:notice_member_invitation_accepted)
      elsif @member_invitation.rejected?
        redirect_to home_path, notice: l(:notice_member_invitation_rejected)
      end
    else
      deny_access
    end
  end

  def accept
    @member_invitation = MemberInvitation.find(params[:id])

    if @member_invitation.accept!(params[:token])
      redirect_to project_path(@member_invitation.project), notice: l(:notice_member_invitation_accepted)
    else
      redirect_to home_path, alert: l(:error_member_invitation)
    end
  end

  def reject
    @member_invitation = MemberInvitation.find(params[:id])
    
    if @member_invitation.reject!(params[:token])
      redirect_to home_path, notice: l(:notice_member_invitation_rejected)
    else
      redirect_to home_path, alert: l(:error_member_invitation)
    end
  end
end
