require 'closure_tree'
require 'configurations'

require 'treelify/acts_as_hierarchy'
require 'treelify/acts_as_resource'
require 'treelify/acts_as_user'
require 'treelify/membership'
require 'treelify/hierarchy'

module Treelify
  include Configurations

  not_configured do |prop|
    raise NoMethodError, "#{prop} must be configured"
  end
end
