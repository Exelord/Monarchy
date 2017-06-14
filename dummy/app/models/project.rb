# frozen_string_literal: true

class Project < ActiveRecord::Base
  acts_as_resource parent_as: :resource
  belongs_to :resource, foreign_key: :parent_id
  has_one :status

  after_create :create_status

  def create_status
    Status.create(project: self, name: 'Monarchy is OK!')
  end
end
