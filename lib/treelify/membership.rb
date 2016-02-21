class Member < ActiveRecord::Base
  has_and_belongs_to_many :roles
  belongs_to :user
  belongs_to :hierarchy
  delegate :resource, to: :hierarchy
  delegate :resource=, to: :hierarchy

  validates :user_id, uniqueness: { scope: :hierarchy_id }
  validates :user, presence: true
  validates :hierarchy, presence: true
end

class Role < ActiveRecord::Base
  has_and_belongs_to_many :members
end
