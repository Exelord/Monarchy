# frozen_string_literal: true
require 'rails/generators/active_record'

module Monarchy
  class SetupGenerator < Rails::Generators::Base
    include Rails::Generators::Migration

    desc 'This generator setups Monarchy'
    source_root File.expand_path('../../templates', __FILE__)

    def setup_monarchy
      template 'config.rb', 'config/initializers/monarchy.rb'

      template 'models/user.rb', 'app/models/user.rb'
<<<<<<< Updated upstream
      template 'models/hierarchy.rb', 'app/models/tonarchy/hierarchy.rb'
=======
<<<<<<< Updated upstream
      template 'models/hierarchy.rb', 'app/models/hierarchy.rb'
=======
      template 'models/hierarchy.rb', 'app/models/monarchy/hierarchy.rb'
>>>>>>> Stashed changes
>>>>>>> Stashed changes

      migration_template 'migrations/hierarchy.rb', 'db/migrate/monarchy_create_hierarchies.rb'
      migration_template 'migrations/membership.rb', 'db/migrate/monarchy_create_memberships.rb'
      migration_template 'migrations/user.rb', 'db/migrate/monarchy_create_users.rb'
    end

    def self.next_migration_number(dirname)
      ActiveRecord::Generators::Base.next_migration_number(dirname)
    end
  end
end
