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
    config.members_access_revoke = false
    config.revoke_strategy = :revoke_member
  end

  not_configured do |property|
    raise Monarchy::Exceptions::ConfigNotDefined, property
  end

  def self.member_class
    Monarchy.configuration.member_class_name.safe_constantize || class_not_defined('Member')
  end

  def self.role_class
    Monarchy.configuration.role_class_name.safe_constantize || class_not_defined('Role')
  end

  def self.user_class
    Monarchy.configuration.user_class_name.safe_constantize || class_not_defined('User')
  end

  private

  def class_not_defined(class_name)
    raise Monarchy::Exceptions::ClassNotDefined, class_name
  end
end
