# frozen_string_literal: true
class Resource < ActiveRecord::Base
  acts_as_resource parent_as: :memo
  belongs_to :memo
end
