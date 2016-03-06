# frozen_string_literal: true
Treelify.configure do |config|
  config.default_role.name = :guest
  config.default_role.level = 0
  config.default_role.inherited = false
end
