# frozen_string_literal: true
module Monarchy
  class Member < ActiveRecord::Base
    self.table_name = 'monarchy_members'

    has_many :members_roles, dependent: :destroy, class_name: 'Monarchy::MembersRole'
    has_many :roles, through: :members_roles, class_name: 'Monarchy::Role'

    belongs_to :user
    belongs_to :hierarchy, class_name: 'Monarchy::Hierarchy'

    delegate :resource, to: :hierarchy
    delegate :resource=, to: :hierarchy

    validates :user_id, uniqueness: { scope: :hierarchy_id }
    validates :user, presence: true
    validates :hierarchy, presence: true

    before_create :set_default_role

    private

    def set_default_role
      roles = self.roles
      roles << Monarchy::Role.find_or_create_by(
        name: Monarchy.configuration.default_role.name,
        inherited: Monarchy.configuration.default_role.inherited,
        level: Monarchy.configuration.default_role.level)
      self.roles = roles.uniq
    end
  end

  class Role < ActiveRecord::Base
    self.table_name = 'monarchy_roles'

    has_many :members_roles, dependent: :destroy, class_name: 'Monarchy::MembersRole'
    has_many :members, through: :members_roles, class_name: 'Monarchy::Member'
  end

  class MembersRole < ActiveRecord::Base
    self.table_name = 'monarchy_members_roles'

    belongs_to :member, class_name: 'Monarchy::Member'
    belongs_to :role, class_name: 'Monarchy::Role'

    validates :role_id, uniqueness: { scope: :member_id }
  end
end
