# frozen_string_literal: true
Monarchy.configure do |config|
  config.default_role.name = :guest
  config.default_role.level = 0
  config.default_role.inherited = false

  # config.user_class = Monarchy::User
  config.member_class = Member
  config.role_class = Role
end
