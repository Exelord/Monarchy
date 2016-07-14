# frozen_string_literal: true
module Monarchy
  class Member < ActiveRecord::Base
    self.table_name = 'monarchy_members'

    has_many :members_roles, dependent: :destroy, class_name: 'Monarchy::MembersRole'
    has_many :roles, -> { order(level: :desc) }, through: :members_roles, class_name: '::Role'

    belongs_to :user
    belongs_to :hierarchy, class_name: 'Monarchy::Hierarchy'

    delegate :resource, :resource_id, :resource_type, to: :hierarchy

    validates :user_id, uniqueness: { scope: :hierarchy_id }
    validates :user, presence: true

    validate :hierarchy_or_resource

    before_create :set_default_role

    scope :accessible_for, (lambda do |user|
      where(hierarchy: Monarchy::Hierarchy.accessible_for(user))
    end)

    def resource=(resource)
      self.hierarchy = resource.hierarchy unless hierarchy
    end

    private

    def set_default_role
      roles = self.roles
      roles << Monarchy::role_class.find_or_create_by(
        name: Monarchy.configuration.default_role.name,
        inherited: Monarchy.configuration.default_role.inherited,
        level: Monarchy.configuration.default_role.level
      )
      self.roles = roles.uniq
    end

    def hierarchy_or_resource
      errors.add(:base, 'Specify a resource or a hierarchy') unless hierarchy
    end
  end

  class Role < ActiveRecord::Base
    self.table_name = 'monarchy_roles'

    has_many :members_roles, dependent: :destroy, class_name: 'Monarchy::MembersRole'
    has_many :members, through: :members_roles, class_name: '::Member'

    belongs_to :inherited_role, class_name: 'Role'

    after_create :default_inherited_role

    private

    def default_inherited_role
      update(inherited_role_id: id) unless inherited_role
    end
  end

  class MembersRole < ActiveRecord::Base
    self.table_name = 'monarchy_members_roles'

    belongs_to :member, class_name: 'Member'
    belongs_to :role, class_name: 'Role'

    validates :role_id, uniqueness: { scope: :member_id }
  end
end
