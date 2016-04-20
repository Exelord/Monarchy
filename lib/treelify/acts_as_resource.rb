# frozen_string_literal: true
module Monarchy
  module ActsAsResource
    extend ActiveSupport::Concern

    module ClassMethods
      def acts_as_resource(options = {})
        parent_as(options[:parent_as]) if options[:parent_as]

        after_create :ensure_hierarchy

        has_many :members, through: :hierarchy
<<<<<<< Updated upstream
        has_one :hierarchy, as: :resource, dependent: :destroy, class_name: 'Monarchy::Hierarchy'
=======
<<<<<<< Updated upstream
        has_one :hierarchy, as: :resource, dependent: :destroy
=======
        has_one :hierarchy, as: :resource, dependent: :destroy, class_name: 'Monarchy::Hierarchy'
>>>>>>> Stashed changes
>>>>>>> Stashed changes

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
<<<<<<< Updated upstream
          joins(:hierarchy).where(tonarchy_hierarchies: { parent_id: resource.hierarchy.id })
=======
<<<<<<< Updated upstream
          joins(:hierarchy).where("hierarchies.parent_id": resource.hierarchy.id)
=======
          joins(:hierarchy).where(monarchy_hierarchies: { parent_id: resource.hierarchy.id })
>>>>>>> Stashed changes
>>>>>>> Stashed changes
        end)

        scope :accessible_for, (lambda do |user|
          joins(:hierarchy)
<<<<<<< Updated upstream
          .joins('INNER JOIN "tonarchy_hierarchy_hierarchies" ON '\
            '"tonarchy_hierarchies"."id" = "tonarchy_hierarchy_hierarchies"."ancestor_id"')
          .joins('INNER JOIN "tonarchy_members" ON '\
            '"tonarchy_members"."hierarchy_id" = "tonarchy_hierarchy_hierarchies"."descendant_id"')
          .where(tonarchy_members: { user_id: user.id }).uniq
=======
<<<<<<< Updated upstream
          .joins('INNER JOIN "hierarchy_hierarchies" ON "hierarchies"."id" = "hierarchy_hierarchies"."ancestor_id"')
          .joins('INNER JOIN "members" ON "members"."hierarchy_id" = "hierarchy_hierarchies"."descendant_id"')
          .where("members.user_id": user.id).uniq
=======
          .joins('INNER JOIN "monarchy_hierarchy_hierarchies" ON '\
            '"monarchy_hierarchies"."id" = "monarchy_hierarchy_hierarchies"."ancestor_id"')
          .joins('INNER JOIN "monarchy_members" ON '\
            '"monarchy_members"."hierarchy_id" = "monarchy_hierarchy_hierarchies"."descendant_id"')
          .where(monarchy_members: { user_id: user.id }).uniq
>>>>>>> Stashed changes
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
        self.hierarchy ||= Monarchy::Hierarchy.create(
=======
<<<<<<< Updated upstream
        self.hierarchy ||= Hierarchy.create(
=======
        self.hierarchy ||= Monarchy::Hierarchy.create(
>>>>>>> Stashed changes
>>>>>>> Stashed changes
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
