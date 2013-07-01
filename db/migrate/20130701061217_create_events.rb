class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.integer :project_id
      t.string :eventable_type
      t.integer :eventable_id
      t.string :title
      t.integer :position
      t.datetime :start_at
      t.datetime :end_at
      t.timestamps
    end
  end
end
