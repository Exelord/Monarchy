class MonarchyCreateHierarchies < ActiveRecord::Migration
  def change
<<<<<<< Updated upstream
    create_table :tonarchy_hierarchies do |t|
=======
<<<<<<< Updated upstream
    create_table :hierarchies do |t|
=======
    create_table :monarchy_hierarchies do |t|
>>>>>>> Stashed changes
>>>>>>> Stashed changes
      t.integer :parent_id
      t.integer :resource_id, null: false
      t.string :resource_type, null: false
      t.timestamps null: false
    end

<<<<<<< Updated upstream
    create_table :tonarchy_hierarchy_hierarchies, id: false do |t|
=======
<<<<<<< Updated upstream
    create_table :hierarchy_hierarchies, id: false do |t|
=======
    create_table :monarchy_hierarchy_hierarchies, id: false do |t|
>>>>>>> Stashed changes
>>>>>>> Stashed changes
      t.integer :ancestor_id, null: false
      t.integer :descendant_id, null: false
      t.integer :generations, null: false
    end

<<<<<<< Updated upstream
    add_index :tonarchy_hierarchy_hierarchies, [:ancestor_id, :descendant_id, :generations],
              unique: true,
              name: 'hierarchy_anc_desc_idx'

    add_index :tonarchy_hierarchy_hierarchies, [:descendant_id], name: 'hierarchy_desc_idx'
=======
<<<<<<< Updated upstream
    add_index :hierarchy_hierarchies, [:ancestor_id, :descendant_id, :generations],
              unique: true,
              name: 'hierarchy_anc_desc_idx'

    add_index :hierarchy_hierarchies, [:descendant_id], name: 'hierarchy_desc_idx'
=======
    add_index :monarchy_hierarchy_hierarchies, [:ancestor_id, :descendant_id, :generations],
              unique: true,
              name: 'hierarchy_anc_desc_idx'

    add_index :monarchy_hierarchy_hierarchies, [:descendant_id], name: 'hierarchy_desc_idx'
>>>>>>> Stashed changes
>>>>>>> Stashed changes
  end
end
