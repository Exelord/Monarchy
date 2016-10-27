# frozen_string_literal: true
module Monarchy
  module ActsAsHierarchy
    extend ActiveSupport::Concern

    module ClassMethods
      def acts_as_hierarchy
        extend Monarchy::ActsAsHierarchy::SupportMethods
        self.table_name = 'monarchy_hierarchies'
        has_closure_tree dependent: :destroy

        has_many :members, class_name: "::#{Monarchy.member_class}", dependent: :destroy
        has_many :users, through: :members, class_name: "::#{Monarchy.user_class}"
        belongs_to :resource, polymorphic: true

        include_scopes

        validates :resource_type, presence: true
        validates :resource_id, uniqueness: { scope: [:resource_type] }, presence: true
      end
    end

    module SupportMethods
      private

      def include_scopes
        scope :in, (lambda do |hierarchy, descendants = true|
          Monarchy::Validators.hierarchy(hierarchy)
          where(id: descendants ? hierarchy.descendants : hierarchy.children)
        end)

        scope :accessible_for, (lambda do |user|
          Monarchy::Validators.user(user)
          where(id: accessible_roots(user).union(accessible_leaves(user)))
        end)
      end

      def accessible_roots(user)
        joins('INNER JOIN "monarchy_hierarchy_hierarchies" ON '\
          '"monarchy_hierarchies"."id" = "monarchy_hierarchy_hierarchies"."ancestor_id"')
          .joins('INNER JOIN "monarchy_members" ON '\
          '"monarchy_members"."hierarchy_id" = "monarchy_hierarchy_hierarchies"."descendant_id"')
          .where(monarchy_members: { user_id: user.id }).distinct
      end

      def accessible_leaves(user)
        descendant_leaves.where('monarchy_hierarchy_hierarchies.descendant_id': descendant_leaves_for_user(user)
            .where('monarchy_roles.inherited': false)
            .select('monarchy_hierarchy_hierarchies.ancestor_id')).union(
              descendant_leaves
                .where('monarchy_hierarchy_hierarchies.ancestor_id': descendant_leaves_for_user(user)
                .where.not('monarchy_roles.inherited': false))
            )
      end

      def descendant_leaves_for_user(user)
        descendant_leaves.joins(members: [:roles]).where(monarchy_members: { user_id: user.id })
      end

      def descendant_leaves
        joins('INNER JOIN "monarchy_hierarchy_hierarchies" ON "monarchy_hierarchies"."id" =' \
          '"monarchy_hierarchy_hierarchies"."descendant_id"')
      end
    end
  end
end

ActiveRecord::Base.send :include, Monarchy::ActsAsHierarchy
