class AddCreatorIdToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :creator_id, :integer
    add_index :projects, :creator_id
  end
end
