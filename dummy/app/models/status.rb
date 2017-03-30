# frozen_string_literal: true

class Status < ActiveRecord::Base
  acts_as_resource parent_as: :project
  belongs_to :project
end
