class TreelifyCreateMemoResource < ActiveRecord::Migration
  def change
    create_table :memos do |t|
      t.string :name
      t.timestamps null: false
    end
  end
end
