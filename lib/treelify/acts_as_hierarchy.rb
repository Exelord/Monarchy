module Treelify
  module ActsAsHierarchy
    extend ActiveSupport::Concern

    module ClassMethods
      def acts_as_hierarchy
        has_closure_tree dependent: :destroy

        has_many :members
        belongs_to :resource, polymorphic: true, dependent: :destroy

        validates :resource, presence: true

        include Treelify::ActsAsHierarchy::InstanceMethods
      end
    end

    module InstanceMethods
      def memberless_ancestors_for(user)
        ancestors.joins('LEFT JOIN members on hierarchies.id = members.hierarchy_id')
                 .where("members.user_id != #{user.id} OR members.id IS NULL")
      end
    end
  end
end

ActiveRecord::Base.send :include, Treelify::ActsAsHierarchy
