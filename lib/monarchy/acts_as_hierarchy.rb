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

        include Monarchy::ActsAsHierarchy::InstanceMethods
      end
    end

    module InstanceMethods
      def accessible_for(user, options = {})
        self.class.accessible_for(user, options).find_by(id: id).present?
      end
    end

    module SupportMethods
      private

      # rubocop:disable all
      def include_scopes
        scope :in, (lambda do |hierarchy, descendants = true|
          Monarchy::Validators.hierarchy(hierarchy)
          where(id: descendants ? hierarchy.descendants : hierarchy.children)
        end)

        scope :accessible_for, (lambda do |user, options = {}|
          Monarchy::Validators.user(user)
          user_id = user.id

          custom_options = accessible_for_options(options)
          where(id: accessible_roots_ids(user_id, custom_options[:parent_access])
                      .union_all(accessible_leaves_ids(user_id, custom_options[:inherited_roles])))
        end)
      end
      # rubocop:enable all

      def accessible_roots_ids(user_id, parent_access)
        accessible_roots = unscoped.joins('INNER JOIN monarchy_hierarchy_hierarchies ON ' \
          'monarchy_hierarchies.id = monarchy_hierarchy_hierarchies.ancestor_id')
                                   .joins('INNER JOIN (SELECT hierarchy_id FROM monarchy_members ' \
              "WHERE monarchy_members.user_id = #{user_id}) as members ON " \
                'members.hierarchy_id = monarchy_hierarchy_hierarchies.descendant_id').select(:id)

        parent_access ? roots_with_children(accessible_roots) : accessible_roots
      end

      def roots_with_children(accessible_roots)
        accessible_children = unscoped.where(parent_id: accessible_roots).select(:id)
        accessible_roots.union_all(accessible_children)
      end

      def accessible_leaves_ids(user_id, inherited_roles = [])
        ancestor_leaves_for_user(user_id, false)
          .select('monarchy_hierarchy_hierarchies.ancestor_id AS id')
          .union_all(descendant_leaves_for_user(user_id, inherited_roles)).select(:id)
      end

      def descendant_leaves_for_user(user_id, inherited_roles = [])
        ancestor_leaves_for_user(user_id, true, inherited_roles)
          .joins('INNER JOIN monarchy_hierarchy_hierarchies AS monarchy_descendants ON ' \
            'monarchy_descendants.ancestor_id = monarchy_hierarchies.id')
          .select('monarchy_descendants.descendant_id AS id')
      end

      def ancestor_leaves_for_user(user_id, inherited, inherited_roles = [])
        unscoped
          .joins('INNER JOIN monarchy_hierarchy_hierarchies ON ' \
            'monarchy_hierarchies.id = monarchy_hierarchy_hierarchies.descendant_id')
          .joins('INNER JOIN (SELECT id, hierarchy_id FROM monarchy_members WHERE ' \
            "user_id = #{user_id}) as monarchy_members ON monarchy_members.hierarchy_id = monarchy_hierarchies.id")
          .joins('INNER JOIN monarchy_members_roles ON monarchy_members_roles.member_id = monarchy_members.id')
          .joins("INNER JOIN (#{inheritance_query(inherited_roles, inherited)}) as " \
            'monarchy_roles ON monarchy_members_roles.role_id = monarchy_roles.id')
      end

      def inheritance_query(inherited_roles, inherited)
        if inherited_roles.present?
          Monarchy.role_class.select(:id, :inherited, :name)
                  .where('inherited = ? OR name IN (?)', inherited, inherited_roles).to_sql
        else
          Monarchy.role_class.select(:id, :inherited).where(inherited: inherited).to_sql
        end
      end

      def accessible_for_options(options = {})
        Monarchy.configuration.accessible_for_options.to_h.merge(options)
      end
    end
  end
end

ActiveRecord::Base.send :include, Monarchy::ActsAsHierarchy
