class MonarchyCreateMemberships < ActiveRecord::Migration
  def change
<<<<<<< Updated upstream
    create_table :tonarchy_members do |t|
=======
<<<<<<< Updated upstream
    create_table :members do |t|
=======
    create_table :monarchy_members do |t|
>>>>>>> Stashed changes
>>>>>>> Stashed changes
      t.belongs_to :user
      t.belongs_to :hierarchy
      t.timestamps null: false
    end

<<<<<<< Updated upstream
    create_table :tonarchy_roles do |t|
=======
<<<<<<< Updated upstream
    create_table :roles do |t|
=======
    create_table :monarchy_roles do |t|
>>>>>>> Stashed changes
>>>>>>> Stashed changes
      t.string :name, null: false
      t.integer :level, default: 0, null: false
      t.boolean :inherited, default: true, null: false
      t.timestamps null: false
    end

<<<<<<< Updated upstream
    add_index :tonarchy_roles, :name, unique: true

    create_table :tonarchy_members_roles do |t|
=======
<<<<<<< Updated upstream
    add_index :roles, :name, unique: true

    create_table :members_roles do |t|
=======
    add_index :monarchy_roles, :name, unique: true

    create_table :monarchy_members_roles do |t|
>>>>>>> Stashed changes
>>>>>>> Stashed changes
      t.belongs_to :role
      t.belongs_to :member
      t.timestamps null: false
    end

<<<<<<< Updated upstream
    add_index :tonarchy_members_roles, [:role_id, :member_id], unique: true
=======
<<<<<<< Updated upstream
    add_index :members_roles, [:role_id, :member_id], unique: true
=======
    add_index :monarchy_members_roles, [:role_id, :member_id], unique: true
>>>>>>> Stashed changes
>>>>>>> Stashed changes
  end
end
