# frozen_string_literal: true
class CreateResourceResource < ActiveRecord::Migration
  def change
    create_table :resources do |t|
      t.string :name
      t.timestamps null: false
    end
  end
end
