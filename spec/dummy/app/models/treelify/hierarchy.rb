# frozen_string_literal: true
<<<<<<< Updated upstream
class Monarchy::Hierarchy < ActiveRecord::Base
  self.table_name = 'tonarchy_hierarchies'
=======
class Monarchy::Hierarchy < ActiveRecord::Base
  self.table_name = 'monarchy_hierarchies'
>>>>>>> Stashed changes
  acts_as_hierarchy
end
