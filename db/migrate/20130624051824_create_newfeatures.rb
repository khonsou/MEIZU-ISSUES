class CreateNewfeatures < ActiveRecord::Migration
  def change
    create_table :newfeatures do |t|
      t.string :title
      t.text :description

      t.timestamps
    end
  end
end
