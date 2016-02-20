class Resourcify < ActiveRecord::Base
  self.abstract_class = true
  acts_as_resource
end
