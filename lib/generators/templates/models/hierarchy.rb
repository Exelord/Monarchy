<<<<<<< Updated upstream
class Monarchy::Hierarchy < ActiveRecord::Base
  self.table_name = 'tonarchy_hierarchies'
=======
<<<<<<< Updated upstream
class Hierarchy < ActiveRecord::Base
=======
class Monarchy::Hierarchy < ActiveRecord::Base
  self.table_name = 'monarchy_hierarchies'
>>>>>>> Stashed changes
>>>>>>> Stashed changes
  acts_as_hierarchy
end
