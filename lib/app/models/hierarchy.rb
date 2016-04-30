# frozen_string_literal: true

require 'closure_tree'

class Hierarchy < ActiveRecord::Base
  acts_as_hierarchy
end
