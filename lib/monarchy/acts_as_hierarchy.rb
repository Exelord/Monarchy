# frozen_string_literal: true
module Monarchy
  module ActsAsHierarchy
    extend ActiveSupport::Concern

    module ClassMethods
      def acts_as_hierarchy
        extend Monarchy::ActsAsHierarchy::SupportMethods
        has_closure_tree dependent: :destroy

        has_many :members, class_name: 'Monarchy::Member', dependent: :destroy
        belongs_to :resource, polymorphic: true, dependent: :destroy

        include_scopes

        validates :resource, presence: true
      end
    end

    module SupportMethods
      private

      def include_scopes
        scope :in, (lambda do |resource|
          where(monarchy_hierarchies: { parent_id: resource.hierarchy.self_and_descendant_ids })
        end)

        scope :accessible_for, (lambda do |user|
          where(id: accessible_roots(user).select(:id)).union(where(id: accessible_leaves(user).select(:id)))
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
        joins('INNER JOIN "monarchy_hierarchy_hierarchies" ON '\
          '"monarchy_hierarchies"."id" = "monarchy_hierarchy_hierarchies"."descendant_id"')
          .joins('INNER JOIN "monarchy_members" ON '\
          '"monarchy_members"."hierarchy_id" = "monarchy_hierarchy_hierarchies"."ancestor_id"')
          .where(monarchy_members: { user_id: user.id }).distinct
      end
    end
  end
end

ActiveRecord::Base.send :include, Monarchy::ActsAsHierarchy
