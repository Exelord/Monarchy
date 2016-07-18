# frozen_string_literal: true
class Monarchy::MembersRole < ActiveRecord::Base
  self.table_name = 'monarchy_members_roles'

  belongs_to :member, class_name: 'Member'
  belongs_to :role, class_name: 'Role'

  validates :role_id, uniqueness: { scope: :member_id }
end
