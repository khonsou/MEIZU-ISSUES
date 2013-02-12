class CreatePushNotifications < ActiveRecord::Migration
  def change
    create_table :push_notifications do |t|
      t.string :type
      t.string :event_name
      t.text :raw_data
      t.references :pusher, polymorphic: true
      t.references :author
      t.references :recipient
      t.boolean :read

      t.timestamps
    end

    add_index :push_notifications, :type
    add_index :push_notifications, [:pusher_id, :pusher_type]
    add_index :push_notifications, :author_id
    add_index :push_notifications, :recipient_id
    add_index :push_notifications, :read
  end
end
