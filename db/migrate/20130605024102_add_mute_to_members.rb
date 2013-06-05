class AddMuteToMembers < ActiveRecord::Migration
  def change
    add_column "members", "mute", :boolean, :default => false, :null => false    
  end
end
