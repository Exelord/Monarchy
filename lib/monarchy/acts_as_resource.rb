# frozen_string_literal: true
module Monarchy
  module ActsAsResource
    extend ActiveSupport::Concern

    module ClassMethods
      def acts_as_resource(options = {})
        extend Monarchy::ActsAsResource::SupportMethods

        parent_as(options[:parent_as]) if options[:parent_as]

        after_create :ensure_hierarchy

        has_many :members, through: :hierarchy, class_name: 'Monarchy::Member'
        has_many :users, through: :members, class_name: 'User'
        has_one :hierarchy, as: :resource, dependent: :destroy, class_name: 'Monarchy::Hierarchy'

        include_scopes

        include Monarchy::ActsAsResource::InstanceMethods
      end
    end

    module SupportMethods
      private

      def parent_as(name)
        define_method "#{name}=" do |value|
          self.parent = value
          super(value)
        end

        define_method "#{name}_id=" do |id|
          class_name = name.to_s.camelize.safe_constantize
          self.parent = class_name.find(id)
          super(id)
        end
      end

      def include_scopes
        scope :in, (lambda do |resource|
          joins(:hierarchy).where(monarchy_hierarchies: { parent_id: resource.hierarchy.self_and_descendant_ids })
        end)

        scope :accessible_for, (lambda do |user|
          where(id: accessible_roots(user).select(:id)).union(where(id: accessible_leaves(user).select(:id)))
        end)
      end

      def accessible_roots(user)
        joins(:hierarchy)
          .joins('INNER JOIN "monarchy_hierarchy_hierarchies" ON '\
        '"monarchy_hierarchies"."id" = "monarchy_hierarchy_hierarchies"."ancestor_id"')
          .joins('INNER JOIN "monarchy_members" ON '\
        '"monarchy_members"."hierarchy_id" = "monarchy_hierarchy_hierarchies"."descendant_id"')
          .where(monarchy_members: { user_id: user.id }).distinct
      end

      def accessible_leaves(user)
        joins(:hierarchy)
          .joins('INNER JOIN "monarchy_hierarchy_hierarchies" ON '\
        '"monarchy_hierarchies"."id" = "monarchy_hierarchy_hierarchies"."descendant_id"')
          .joins('INNER JOIN "monarchy_members" ON '\
        '"monarchy_members"."hierarchy_id" = "monarchy_hierarchy_hierarchies"."ancestor_id"')
          .where(monarchy_members: { user_id: user.id }).distinct
      end
    end

    module InstanceMethods
      def parent
        @parent = hierarchy.try(:parent).try(:resource) || @parent
      end

      def parent=(resource)
        if hierarchy
          hierarchy.update(parent: resource.try(:hierarchy))
        else
          @parent = resource
        end
      end

      def children
        @children ||= children_resources
      end

      def children=(array)
        hierarchy.update(children: hierarchies_for(array)) if hierarchy
        @children = array
      end

      private

      def ensure_hierarchy
        self.hierarchy ||= Monarchy::Hierarchy.create(
          resource: self,
          parent: parent.try(:hierarchy),
          children: hierarchies_for(children)
        )
      end

      def children_resources
        c = hierarchy.try(:children)
        return nil if c.nil?
        c.includes(:resource).map(&:resource)
      end

      def hierarchies_for(array)
        Array(array).map(&:hierarchy)
      end
    end
  end
end

ActiveRecord::Base.send :include, Monarchy::ActsAsResource
