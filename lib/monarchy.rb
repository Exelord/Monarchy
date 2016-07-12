# frozen_string_literal: true
require 'closure_tree'
require 'configurations'
require 'active_record_union'

require 'monarchy/acts_as_hierarchy'
require 'monarchy/acts_as_resource'
require 'monarchy/acts_as_user'
require 'monarchy/membership'
require 'monarchy/engine'

module Monarchy
  include Configurations

  not_configured do |prop|
    raise NoMethodError, "#{prop} must be configured"
  end

  def self.member_class
    Monarchy.configuration.member_class || Monarchy::Member
  end

  def self.role_class
    Monarchy.configuration.role_class || Monarchy::Role
  end
end
