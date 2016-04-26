class MonarchyCreateMemberships < ActiveRecord::Migration
  def change
    create_table :monarchy_members do |t|
      t.belongs_to :user
      t.belongs_to :hierarchy
      t.timestamps null: false
    end

    create_table :monarchy_roles do |t|
      t.string :name, null: false
      t.integer :level, default: 0, null: false
      t.boolean :inherited, default: false, null: false
      t.timestamps null: false
    end

    add_index :monarchy_roles, :name, unique: true

    create_table :monarchy_members_roles do |t|
      t.belongs_to :role
      t.belongs_to :member
      t.timestamps null: false
    end

    add_index :monarchy_members_roles, [:role_id, :member_id], unique: true
  end
end
