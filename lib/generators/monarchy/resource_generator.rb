# frozen_string_literal: true
require 'rails/generators/active_record'

module Monarchy
  class ResourceGenerator < Rails::Generators::NamedBase
    include Rails::Generators::Migration

    desc 'This generator creates a resourcify model'
    source_root File.expand_path('../../templates', __FILE__)

    def create_resource_file
      template 'models/resource.rb', "app/models/#{file_name}.rb"
      migration_template 'migrations/resource.rb', "db/migrate/create_#{file_name}_resource.rb"
    end

    def self.next_migration_number(dirname)
      ActiveRecord::Generators::Base.next_migration_number(dirname)
    end
  end
end
