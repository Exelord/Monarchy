# frozen_string_literal: true
module Monarchy
  module ActsAsHierarchy
    extend ActiveSupport::Concern

    module ClassMethods
      def acts_as_hierarchy
        has_closure_tree dependent: :destroy

        has_many :members, class_name: 'Monarchy::Member'
        belongs_to :resource, polymorphic: true, dependent: :destroy

        validates :resource, presence: true

        include Monarchy::ActsAsHierarchy::InstanceMethods
      end
    end

    module InstanceMethods
      def memberless_ancestors_for(user)
        ancestors.joins('LEFT JOIN monarchy_members on monarchy_hierarchies.id = monarchy_members.hierarchy_id')
                 .where("monarchy_members.user_id != #{user.id} OR monarchy_members.id IS NULL")
      end
    end
  end
end

ActiveRecord::Base.send :include, Monarchy::ActsAsHierarchy
