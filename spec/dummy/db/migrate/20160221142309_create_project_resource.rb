# frozen_string_literal: true
class CreateProjectResource < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :name
      t.timestamps null: false
    end
  end
end
