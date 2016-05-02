# frozen_string_literal: true
class Monarchy::Hierarchy < ActiveRecord::Base
  self.table_name = 'monarchy_hierarchies'
  acts_as_hierarchy
end
