Monarchy.configure do |config|
  config.default_role.name = :guest
  config.default_role.level = 0
  config.default_role.inherited = false

  config.member_class = nil
  config.role_class = nil
end
