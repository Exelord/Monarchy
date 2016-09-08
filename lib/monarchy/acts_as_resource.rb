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

        has_many :members, through: :hierarchy, class_name: "::#{Monarchy.member_class}"
        has_many :users, through: :members, class_name: "::#{Monarchy.user_class}"
        has_one :hierarchy, as: :resource, dependent: :destroy, class_name: 'Monarchy::Hierarchy'

        include_scopes

        include Monarchy::ActsAsResource::InstanceMethods
      end
    end

    module SupportMethods
      attr_accessor :parentize, :acting_as_resource, :automatic_hierarchy

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
        self.parentize = name
      end

      def include_scopes
        scope :in, (lambda do |resource|
          Monarchy::Validators.resource(resource)
          joins(:hierarchy).where(monarchy_hierarchies: { parent_id: resource.hierarchy.self_and_descendants })
        end)

        scope :accessible_for, (lambda do |user|
          joins(:hierarchy).where(monarchy_hierarchies: { id: Monarchy::Hierarchy.accessible_for(user) })
        end)
      end
    end

    module InstanceMethods
      def parent
        @parent = hierarchy.try(:parent).try(:resource) || @parent
      end

      def parent=(resource)
        Monarchy::Validators.resource(resource, true)
        hierarchy.update(parent: resource.try(:ensure_hierarchy)) if hierarchy
        @parent = resource
      end

      def children
        @children ||= children_resources
      end

      def children=(array)
        hierarchy.update(children: hierarchies_for(array)) if hierarchy
        @children = array
      end

      def ensure_hierarchy(force = false)
        self.hierarchy ||= Monarchy::Hierarchy.create(
          resource: self,
          parent: parent.try(:hierarchy),
          children: hierarchies_for(children)
        ) if self.class.automatic_hierarchy || force
      end

      private

      def assign_parent(force = false)
        parentize = self.class.parentize

        if parentize
          was_changed = changes["#{parentize}_id"] || changes["#{parentize}_type"]
          Monarchy::Validators.resource(send(parentize), true)
          self.parent = send(parentize) if was_changed || force
        end
      end

      def children_resources
        c = hierarchy.try(:children)
        return nil if c.nil?
        c.includes(:resource).map(&:resource)
      end

      def hierarchies_for(array)
        array.compact! if array
        Array(array).map { |resource| Monarchy::Validators.resource(resource) || resource.hierarchy }
      end
    end
  end
end

ActiveRecord::Base.send :include, Monarchy::ActsAsResource
