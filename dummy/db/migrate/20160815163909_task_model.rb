class TaskModel < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string :name
      t.integer :resource_id
      t.string :resource_type
      t.timestamps null: false
    end
  end
end
