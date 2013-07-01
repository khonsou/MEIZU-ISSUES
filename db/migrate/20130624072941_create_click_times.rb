class CreateClickTimes < ActiveRecord::Migration
  def change
    create_table :click_times do |t|
      t.integer :user_id
      t.datetime :click_time
      t.timestamps
    end
  end
end
