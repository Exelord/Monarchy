# frozen_string_literal: true

module Monarchy
  module ActsAsMember
    extend ActiveSupport::Concern

    module ClassMethods
      def acts_as_member
        extend Monarchy::ActsAsMember::SupportMethods

        self.table_name = 'monarchy_members'

        delegate :resource, :resource_id, :resource_type, to: :hierarchy

        include_relationships
        include_validators
        include_callbacks
        include_scopes

        include Monarchy::ActsAsMember::InstanceMethods
      end
    end

    module SupportMethods
      def include_scopes
        scope :accessible_for, (lambda do |user|
          Monarchy::Validators.user(user)
          where(hierarchy: Monarchy.hierarchy_class.accessible_for(user))
        end)

        scope :with_access_to, (lambda do |resource|
          Monarchy::Validators.resource(resource)
          where(id: with_ancestors_access(resource).union(with_descendants_access(resource)))
        end)
      end

      def include_callbacks
        after_destroy :revoke_access, if: :members_access_revoke?
      end

      def include_validators
        validates :user_id, uniqueness: { scope: :hierarchy_id }
        validates :user, presence: true
        validate :hierarchy_or_resource
      end

      def include_relationships
        has_many :members_roles, dependent: :destroy, class_name: 'Monarchy::MembersRole'
        has_many :roles, -> { order(level: :desc) }, through: :members_roles, class_name: "::#{Monarchy.role_class}"

        belongs_to :user, class_name: "::#{Monarchy.user_class}"
        belongs_to :hierarchy, class_name: "::#{Monarchy.hierarchy_class}"
      end

      private

      def with_ancestors_access(resource)
        unscoped.where(hierarchy: resource.hierarchy.self_and_ancestors)
                .joins(:roles).where(monarchy_roles: { inherited: true })
      end

      def with_descendants_access(resource)
        unscoped.where(hierarchy: resource.hierarchy.descendants)
      end
    end

    module InstanceMethods
      def resource=(resource)
        Monarchy::Validators.resource(resource)
        self.hierarchy = resource.hierarchy unless hierarchy
      end

      private

      def revoke_access
        user.revoke_access(resource, resource.hierarchy.descendants)
      end

      def members_access_revoke?
        Monarchy.configuration.members_access_revoke
      end

      def hierarchy_or_resource
        errors.add(:base, 'Specify a resource or a hierarchy') unless hierarchy
      end
    end
  end
end

ActiveRecord::Base.send :include, Monarchy::ActsAsMember
