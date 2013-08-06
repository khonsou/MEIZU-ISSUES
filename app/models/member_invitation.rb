class MemberInvitation < ActiveRecord::Base
  belongs_to :project
  belongs_to :user
  belongs_to :inviter, class_name: 'User'
  has_many :push_notifications, as: :pusher, dependent: :destroy

  before_validation :generate_token, :init_state, on: :create
  validates :project, presence: true

  before_create :bind_inviter
  before_save :bind_user
  after_create :notify

  def self.invite(project, mails, description = nil, inviter = nil)
    mails.map do |mail|
      pending_member_invitations = MemberInvitation.where(:project_id => project.id, :mail => mail, :state => "pending")
      members = Member.where(:project_id => project.id, :user_id => User.find_by_login(mail))
      if pending_member_invitations.blank? && members.blank?
        create(project: project, mail: mail, description: description, inviter: inviter)
      else
        pending_member_invitations.last.updated_at = Time.now
        pending_member_invitations.last.save
      end
    end
  end

  def verify(token)
    token == self.token
  end

  def accept!(token)
    return false if state != 'pending' || token != self.token
    if self.update_attributes(state: 'accepted')
      self.project.members << Member.new(:role_ids => [Role.default.id], :user => User.current)
      true
    end
  end

  def reject!(token)
    return false if state != 'pending' || token != self.token
    self.update_attributes(state: 'rejected')
  end

  def accepted?
    state == 'accepted'
  end

  def rejected?
    state == 'rejected'
  end

  def pending?
    state == 'pending'
  end

  def true_user
    self.user || User.where(:mail => self.mail).first
  end

  protected

  def generate_token
    self.token = SecureRandom.urlsafe_base64 if self.token.blank?
    self.token
  end

  def init_state
    self.state = 'pending'
  end

  def bind_inviter
    self.inviter ||= User.current
  end

  def bind_user
    self.user = User.find_by_mail(self.mail)
  end

  def notify
    PushNotification::MemberInvitationNotification.notify(self, 'create')
  end
end
