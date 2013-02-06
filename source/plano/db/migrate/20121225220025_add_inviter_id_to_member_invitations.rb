class AddInviterIdToMemberInvitations < ActiveRecord::Migration
  def change
    add_column :member_invitations, :inviter_id, :integer
    add_index :member_invitations, :inviter_id
  end
end
