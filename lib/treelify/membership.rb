class Member < ActiveRecord::Base
  has_many :members_roles
  has_many :roles, through: :members_roles

  belongs_to :user
  belongs_to :hierarchy

  delegate :resource, to: :hierarchy
  delegate :resource=, to: :hierarchy

  validates :user_id, uniqueness: { scope: :hierarchy_id }
  validates :user, presence: true
  validates :hierarchy, presence: true

  before_create :set_default_role

  private

  def set_default_role
    roles = self.roles
    roles << Role.find_or_create_by(name: :guest, inherited: false)
    self.roles = roles.uniq
  end
end

class Role < ActiveRecord::Base
  has_many :members_roles
  has_many :members, through: :members_roles
end

class MembersRole < ActiveRecord::Base
  belongs_to :member
  belongs_to :role

  validates :role_id, uniqueness: { scope: :member_id }
end
