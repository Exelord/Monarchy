class TreelifyCreateHierarchies < ActiveRecord::Migration
  def change
    create_table :treelify_hierarchies do |t|
      t.integer :parent_id
      t.integer :resource_id, null: false
      t.string :resource_type, null: false
      t.timestamps null: false
    end

    create_table :treelify_hierarchy_hierarchies, id: false do |t|
      t.integer :ancestor_id, null: false
      t.integer :descendant_id, null: false
      t.integer :generations, null: false
    end

    add_index :treelify_hierarchy_hierarchies, [:ancestor_id, :descendant_id, :generations],
              unique: true,
              name: 'hierarchy_anc_desc_idx'

    add_index :treelify_hierarchy_hierarchies, [:descendant_id], name: 'hierarchy_desc_idx'
  end
end
