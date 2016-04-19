# frozen_string_literal: true
class Treelify::Hierarchy < ActiveRecord::Base
  self.table_name = 'treelify_hierarchies'
  acts_as_hierarchy
end
