# frozen_string_literal: true
class Project < ActiveRecord::Base
  acts_as_resource parent_as: :resource
  belongs_to :resource
end
