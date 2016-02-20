class Hierarchy < ActiveRecord::Base
  acts_as_tree dependent: :destroy
  acts_as_hierarchy
end
