# frozen_string_literal: true
class Monarchy::Role < ActiveRecord::Base
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
