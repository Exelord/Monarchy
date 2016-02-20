class TreelifyCreate<%= class_name %>Resource < ActiveRecord::Migration
  def change
    create_table :<%= file_name.pluralize %> do |t|
      t.timestamps null: false
    end
  end
end
