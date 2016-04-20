# frozen_string_literal: true
module Monarchy
  module ActsAsHierarchy
    extend ActiveSupport::Concern

    module ClassMethods
      def acts_as_hierarchy
        has_closure_tree dependent: :destroy

<<<<<<< Updated upstream
        has_many :members, class_name: 'Monarchy::Member'
=======
<<<<<<< Updated upstream
        has_many :members
=======
        has_many :members, class_name: 'Monarchy::Member'
>>>>>>> Stashed changes
>>>>>>> Stashed changes
        belongs_to :resource, polymorphic: true, dependent: :destroy

        validates :resource, presence: true

        include Monarchy::ActsAsHierarchy::InstanceMethods
      end
    end

    module InstanceMethods
      def memberless_ancestors_for(user)
<<<<<<< Updated upstream
        ancestors.joins('LEFT JOIN tonarchy_members on tonarchy_hierarchies.id = tonarchy_members.hierarchy_id')
                 .where("tonarchy_members.user_id != #{user.id} OR tonarchy_members.id IS NULL")
=======
<<<<<<< Updated upstream
        ancestors.joins('LEFT JOIN members on hierarchies.id = members.hierarchy_id')
                 .where("members.user_id != #{user.id} OR members.id IS NULL")
=======
        ancestors.joins('LEFT JOIN monarchy_members on monarchy_hierarchies.id = monarchy_members.hierarchy_id')
                 .where("monarchy_members.user_id != #{user.id} OR monarchy_members.id IS NULL")
>>>>>>> Stashed changes
>>>>>>> Stashed changes
      end
    end
  end
end

ActiveRecord::Base.send :include, Monarchy::ActsAsHierarchy
