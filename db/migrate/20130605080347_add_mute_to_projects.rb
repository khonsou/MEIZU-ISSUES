class AddMuteToProjects < ActiveRecord::Migration
  def change
    add_column "projects", "mute", :boolean, :default => false, :null => false        
  end
end
