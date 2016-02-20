class Hierarchy < ActiveRecord::Base
  acts_as_tree

  has_many :members
  belongs_to :resource, polymorphic: true
end
