# frozen_string_literal: true

class Task < ActiveRecord::Base
  acts_as_resource parent_as: :resource
  belongs_to :resource, polymorphic: true
end
