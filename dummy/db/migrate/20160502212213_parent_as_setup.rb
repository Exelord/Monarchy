class ParentAsSetup < ActiveRecord::Migration
  def change
    remove_column :resources, :memo_id
    add_column :projects, :resource_id, :integer
    add_column :memos, :project_id, :integer
  end
end
