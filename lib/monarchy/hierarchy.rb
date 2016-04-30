frozen_string_literal: true
# TODO: Fix internal hierarchy model (closure tree not working with internal model)

require 'closure_tree'

class Hierarchy < ActiveRecord::Base
  acts_as_hierarchy
end
