module Treelify
  module ActsAsResource
    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods
      def acts_as_resource
        has_many :members, through: :hierarchy
        has_one :hierarchy, as: :resource, dependent: :destroy

        scope :in, (lambda do |resource|
          joins(:hierarchy).where("hierarchies.parent_id": resource.hierarchy.id)
        end)

        scope :accessible_by, (lambda do |user|
          joins(:hierarchy)
          .joins('INNER JOIN "hierarchy_hierarchies" ON "hierarchies"."id" = "hierarchy_hierarchies"."ancestor_id"')
          .joins('INNER JOIN "members" ON "members"."hierarchy_id" = "hierarchy_hierarchies"."descendant_id"')
          .where("members.user_id": user.id).uniq
        end)

        after_create :ensure_hierarchy

        def ensure_hierarchy
          unless hierarchy
            Hierarchy.create(resource: self)
          end
        end

        include Treelify::ActsAsResource::LocalInstanceMethods
      end
    end

    module LocalInstanceMethods
      def parent
        hierarchy.parent.resource
      end

      def parent=(resource)
        hierarchy.update(parent: resource.hierarchy)
      end
    end

  end
end

ActiveRecord::Base.send :include, Treelify::ActsAsResource
