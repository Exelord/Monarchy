require 'rails/generators/active_record'

module Treelify
  class SetupGenerator < Rails::Generators::Base
    include Rails::Generators::Migration

    desc "This generator setups Treelify"
    source_root File.expand_path("../../templates", __FILE__)

    def setup_treelify
      template "models/resourcify.rb", "app/models/resourcify.rb"
      template "models/hierarchy.rb", "app/models/hierarchy.rb"
      template "models/member.rb", "app/models/member.rb"
      template "models/role.rb", "app/models/role.rb"
      template "models/user.rb", "app/models/user.rb"

      migration_template "migrations/hierarchy.rb", "db/migrate/treelify_create_hierarchies.rb"
      migration_template "migrations/membership.rb", "db/migrate/treelify_create_memberships.rb"
      migration_template "migrations/user.rb", "db/migrate/treelify_create_users.rb"
    end

    def self.next_migration_number(dirname)
      ActiveRecord::Generators::Base.next_migration_number(dirname)
    end
  end
end
