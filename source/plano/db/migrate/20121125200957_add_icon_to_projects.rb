class AddIconToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :icon, :string
  end
end
