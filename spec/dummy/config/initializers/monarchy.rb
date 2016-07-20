# frozen_string_literal: true
Monarchy.configure do |config|
  config.default_role.name = :guest
  config.default_role.level = 0
  config.default_role.inherited = false

  config.user_class_name = 'User'
  config.role_class_name = 'Role'
  config.member_class_name = 'Member'
end
