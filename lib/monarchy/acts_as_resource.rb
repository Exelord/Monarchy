# frozen_string_literal: true

module Monarchy
  module ActsAsResource
    extend ActiveSupport::Concern

    module ClassMethods
      def acts_as_resource(options = {})
        extend Monarchy::ActsAsResource::SupportMethods
        setup_acting

        parent_as(options[:parent_as]) if options[:parent_as]

        after_update :assign_parent
        after_create :ensure_hierarchy, :assign_parent

        include_relationships
        include_scopes

        include Monarchy::ActsAsResource::InstanceMethods
      end
    end

    module SupportMethods
      attr_accessor :automatic_hierarchy
      attr_reader :acting_as_resource, :parentize_name

      def default_role_name
        Monarchy.configuration.inherited_default_role
      end

      def default_role
        @default_role ||= Monarchy.role_class.find_by(name: default_role_name)
      end

      private

      def setup_acting
        Monarchy.resource_classes << self
        @acting_as_resource = true
        @automatic_hierarchy = true
      end

      def parent_as(name)
        @parentize_name = name
      end

      # rubocop:disable all
      def include_scopes
        scope :in, (lambda do |resource, descendants = true|
          Monarchy::Validators.resource(resource)
          hierarchy = Monarchy.hierarchy_class.hierarchies_for(resource)
          hierarchies = Monarchy.hierarchy_class.in(hierarchy, descendants)
          joins(:hierarchy).where(monarchy_hierarchies: { id: hierarchies })
        end)

        scope :accessible_for, (lambda do |user, options = {}|
          Monarchy::Validators.user(user)
          joins(:hierarchy).where(monarchy_hierarchies: { id: Monarchy.hierarchy_class
                                                                      .accessible_for(user, options) })
        end)
      end
      # rubocop:enable all

      def include_relationships
        has_many :members, through: :hierarchy, class_name: "::#{Monarchy.member_class}"
        has_many :users, through: :members, class_name: "::#{Monarchy.user_class}"
        has_one :hierarchy, as: :resource, dependent: :destroy, class_name: "::#{Monarchy.hierarchy_class}"
      end
    end

    module InstanceMethods
      def parent
        @parent = parent_resource || @parent
      end

      def parent=(resource)
        Monarchy::Validators.resource(resource, true)
        hierarchy&.update(parent: resource.try(:ensure_hierarchy))
        @parent = resource
      end

      def children
        @children ||= children_resources
      end

      def children=(array)
        hierarchy&.update(children: children_hierarchies(array))
        @children = array
      end

      def ensure_hierarchy(force = false)
        return nil unless self.class.automatic_hierarchy || force

        self.hierarchy ||= Monarchy.hierarchy_class.create(
          resource: self,
          parent: parent.try(:hierarchy),
          children: children_hierarchies(children)
        )
      end

      def accessible_for(user, options = {})
        Monarchy::Validators.user(user)
        hierarchy.accessible_for(user, options)
      end

      private

      def assign_parent(force = false)
        parentize = self.class.parentize_name
        return unless parentize

        keys = relation_keys(parentize)
        was_changed = changes[keys[:foreign_key]] || changes[keys[:foreign_type]]
        Monarchy::Validators.resource(send(parentize), true, false)
        self.parent = send(parentize) if was_changed || force
      end

      def relation_keys(relation_name)
        reflection = self.class.reflections[relation_name.to_s]
        { foreign_key: reflection.foreign_key, foreign_type: reflection.foreign_type }
      end

      def children_resources
        resource_hierarchy = Monarchy.hierarchy_class.hierarchies_for(self)
        hierarchy_children = Monarchy.hierarchy_class.children_for(resource_hierarchy)
        hierarchy_children.includes(:resource).map(&:resource)
      end

      def parent_resource
        resource_hierarchy = Monarchy.hierarchy_class.hierarchies_for(self)
        hierarchy_parent = Monarchy.hierarchy_class.parents_for(resource_hierarchy)
        hierarchy_parent.first&.resource
      end

      def children_hierarchies(array)
        array&.compact!
        Array(array).map { |resource| Monarchy::Validators.resource(resource).hierarchy }
      end
    end
  end
end

ActiveRecord::Base.send :include, Monarchy::ActsAsResource
