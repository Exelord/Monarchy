class TreelifyCreateMemberships < ActiveRecord::Migration
  def change
    create_table :members do |t|
      t.belongs_to :user
      t.belongs_to :hierarchy
      t.timestamps null: false
    end

    create_table :roles do |t|
      t.string :name
      t.integer :level
      t.timestamps null: false
    end

    create_table :members_roles do |t|
      t.belongs_to :role
      t.belongs_to :member
      t.timestamps null: false
    end
  end
end
