Monarchy.configure do |config|
  config.default_role.name = :guest
  config.default_role.level = 0
  config.default_role.inherited = false

  config.member_class = Monarchy::Member
  config.role_class = Monarchy::Role
  # config.user_class = User
end
