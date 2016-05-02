# frozen_string_literal: true
module Monarchy
  module ActsAsResource
    extend ActiveSupport::Concern

    module ClassMethods
      def acts_as_resource(options = {})
        parent_as(options[:parent_as]) if options[:parent_as]

        after_create :ensure_hierarchy

        has_many :members, through: :hierarchy, dependent: :destroy, class_name: 'Monarchy::Member'
        has_one :hierarchy, as: :resource, dependent: :destroy, class_name: 'Monarchy::Hierarchy'

        include_scopes

        include Monarchy::ActsAsResource::InstanceMethods
      end

      private

      def parent_as(name)
        define_method "#{name}=" do |value|
          super(value)
          self.parent = value
        end
      end

      # rubocop:disable MethodLength
      def include_scopes
        scope :in, (lambda do |resource|
          joins(:hierarchy).where(monarchy_hierarchies: { parent_id: resource.hierarchy.id })
        end)

        scope :accessible_for, (lambda do |user|
          joins(:hierarchy)
            .joins('INNER JOIN "monarchy_hierarchy_hierarchies" ON '\
              '"monarchy_hierarchies"."id" = "monarchy_hierarchy_hierarchies"."ancestor_id"')
            .joins('INNER JOIN "monarchy_members" ON '\
              '"monarchy_members"."hierarchy_id" = "monarchy_hierarchy_hierarchies"."descendant_id"')
            .where(monarchy_members: { user_id: user.id }).distinct
        end)
      end
    end
    # rubocop:enable MethodLength

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
