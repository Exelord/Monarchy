# frozen_string_literal: true
require 'closure_tree'
require 'configurations'
require 'active_record_union'

require 'monarchy/exceptions'
require 'monarchy/validators'
require 'monarchy/tasks'
require 'monarchy/engine'

require 'monarchy/acts_as_role'
require 'monarchy/acts_as_member'
require 'monarchy/acts_as_user'
require 'monarchy/acts_as_resource'
require 'monarchy/acts_as_hierarchy'

module Monarchy
  cattr_accessor :resource_classes

  def self.resource_classes
    @resource_classes ||= []
  end

  include Configurations

  configuration_defaults do |config|
    config.member_class_name = 'Monarchy::Member'
    config.role_class_name = 'Monarchy::Role'
    config.member_force_revoke = false
  end

  not_configured do |prop|
    raise NoMethodError, "Monarchy requires a #{prop} to be configured"
  end

  def self.member_class
    Monarchy.configuration.member_class_name.safe_constantize
  end

  def self.role_class
    Monarchy.configuration.role_class_name.safe_constantize
  end

  def self.user_class
    klass = Monarchy.configuration.user_class_name.safe_constantize
    klass ? klass : raise(ArgumentError, 'User class has to be initialized or exist!')
  end
end
