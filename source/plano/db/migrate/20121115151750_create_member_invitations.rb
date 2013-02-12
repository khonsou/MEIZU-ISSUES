class CreateMemberInvitations < ActiveRecord::Migration
  def change
    create_table :member_invitations do |t|
      t.references :project
      t.string :mail
      t.string :token
      t.string :state
      t.references :user
      t.text :description

      t.timestamps
    end

    add_index :member_invitations, :project_id
    add_index :member_invitations, :mail
    add_index :member_invitations, :token
    add_index :member_invitations, :state
    add_index :member_invitations, :user_id
  end
end
