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
      t.integer :inherited_role_id
      t.boolean :inherited, default: false, null: false
      t.timestamps null: false
    end

    create_table :monarchy_members_roles do |t|
      t.belongs_to :role
      t.belongs_to :member
      t.timestamps null: false
    end

    add_index :monarchy_hierarchies, :parent_id
    add_index :monarchy_hierarchies, :resource_id

    add_index :monarchy_members, :hierarchy_id
    add_index :monarchy_members, :user_id

    add_index :monarchy_roles, :level
    add_index :monarchy_roles, :inherited
    add_index :monarchy_roles, :inherited_role_id
    add_index :monarchy_roles, :name, unique: true

    add_index :monarchy_members_roles, [:role_id, :member_id], unique: true
    add_index :monarchy_members_roles, :member_id
    add_index :monarchy_members_roles, :role_id
  end
end
