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
          user_id = user.id
          where(id: accessible_roots_ids(user_id).union(accessible_leaves_ids(user_id)))
        end)
      end

      def accessible_roots_ids(user_id)
        unscoped.joins('INNER JOIN monarchy_hierarchy_hierarchies ON ' \
          'monarchy_hierarchies.id = monarchy_hierarchy_hierarchies.ancestor_id')
                .joins('INNER JOIN (SELECT hierarchy_id FROM monarchy_members ' \
              "WHERE monarchy_members.user_id = #{user_id}) as members ON " \
                'members.hierarchy_id = monarchy_hierarchy_hierarchies.descendant_id').select(:id)
      end

      def accessible_leaves_ids(user_id)
        ancestor_leaves_for_user(user_id)
          .select('monarchy_hierarchy_hierarchies.ancestor_id AS id')
          .union(descendant_leaves_for_user(user_id)).select(:id)
      end

      def ancestor_leaves_for_user(user_id, inherited = false)
        inherited = inherited ? 't' : 'f'

        unscoped
          .joins('INNER JOIN monarchy_hierarchy_hierarchies ON ' \
            'monarchy_hierarchies.id = monarchy_hierarchy_hierarchies.descendant_id')
          .joins('INNER JOIN (SELECT id, hierarchy_id FROM monarchy_members WHERE ' \
            "user_id = #{user_id}) as monarchy_members ON monarchy_members.hierarchy_id = monarchy_hierarchies.id")
          .joins('INNER JOIN monarchy_members_roles ON monarchy_members_roles.member_id = monarchy_members.id')
          .joins("INNER JOIN (SELECT id, inherited FROM monarchy_roles WHERE inherited = '#{inherited}') as " \
            'monarchy_roles ON monarchy_members_roles.role_id = monarchy_roles.id')
      end

      def descendant_leaves_for_user(user_id)
        ancestor_leaves_for_user(user_id, true)
          .joins('INNER JOIN monarchy_hierarchy_hierarchies AS monarchy_descendants ON ' \
            'monarchy_descendants.ancestor_id = monarchy_hierarchies.id')
          .select('monarchy_descendants.descendant_id AS id')
      end
    end
  end
end

ActiveRecord::Base.send :include, Monarchy::ActsAsHierarchy
