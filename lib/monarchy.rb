# frozen_string_literal: true
require 'closure_tree'
require 'configurations'
require 'active_record_union'

require 'monarchy/acts_as_hierarchy'
require 'monarchy/acts_as_resource'
require 'monarchy/acts_as_user'
require 'monarchy/engine'

module Monarchy
  cattr_accessor :resource_classes

  def self.resource_classes
    @resource_classes ||= []
  end

  include Configurations

  configuration_defaults do |config|
    config.member_class = Monarchy::Member
    config.role_class = Monarchy::Role
    # config.user_class = Monarchy::User
  end

  not_configured do |prop|
    raise NoMethodError, "#{prop} must be configured"
  end

  def self.member_class
    Monarchy.configuration.member_class
  end

  def self.role_class
    Monarchy.configuration.role_class
  end
end
