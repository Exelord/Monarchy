# frozen_string_literal: true
class MonarchyCreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.timestamps null: false
    end
  end
end
