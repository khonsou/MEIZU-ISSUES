class AddPositionToMembers < ActiveRecord::Migration
  def change
    add_column :members, :position, :integer
  end
end
