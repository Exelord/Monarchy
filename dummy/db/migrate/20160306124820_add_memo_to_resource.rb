# frozen_string_literal: true
class AddMemoToResource < ActiveRecord::Migration
  def change
    add_column :resources, :memo_id, :integer
  end
end
