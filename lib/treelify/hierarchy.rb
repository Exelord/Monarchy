class Hierarchy < ActiveRecord::Base
  has_closure_tree dependent: :destroy
  has_many :members
  belongs_to :resource, polymorphic: true

  validates :resource, presence: true
end
