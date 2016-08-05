Monarchy.configure do |config|
  config.default_role.name = :guest
  config.default_role.level = 0
  config.default_role.inherited = false

  config.member_class_name = 'Monarchy::Member'
  config.role_class_name = 'Monarchy::Role'
  # config.user_class_name = 'User'

  # config.member_force_revoke = true
  # config.restricted_role_names = ['member']
end
