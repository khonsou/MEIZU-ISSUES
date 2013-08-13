class AddIssuesCountToProject < ActiveRecord::Migration
  def self.up
    add_column :projects, :issues_count, :integer, :default => 0 

    execute <<-SQL
      update projects set projects.issues_count = (select count(id) from issues where issues.project_id = projects.id)
      SQL
  end
 
  def self.down
  	remove_column :projects, :issues_count 
  end

end
