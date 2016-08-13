# frozen_string_literal: true
module Monarchy
  module ActsAsUser
    extend ActiveSupport::Concern

    module ClassMethods
      def acts_as_user
        has_many :members, class_name: "::#{Monarchy.member_class}", dependent: :destroy
        has_many :hierarchies, through: :members, class_name: 'Monarchy::Hierarchy'

        scope :accessible_for, (lambda do |user|
          where(id: Monarchy::Hierarchy.accessible_for(user)
                                       .joins(members: [:user]).select(:user_id)).union(where(id: user.id))
        end)

        include Monarchy::ActsAsUser::InstanceMethods
      end
    end

    module InstanceMethods
      def roles_for(resource, inheritence = true)
        return Monarchy.role_class.none unless resource.hierarchy
        accessible_roles_for(resource, inheritence)
      end

      def member_for(resource)
        resource.hierarchy.members.where(monarchy_members: { user_id: id }).first
      end

      def grant(role_name, resource)
        ActiveRecord::Base.transaction do
          grant_or_create_member(role_name, resource)
        end
      end

      def revoke_access(resource, hierarchy_ids = nil)
        hierarchy_ids ||= resource.hierarchy.self_and_descendant_ids
        members_for(hierarchy_ids).delete_all
      end

      def revoke_role(role_name, resource)
        revoking_role(role_name, resource)
      end

      def revoke_role!(role_name, resource)
        revoking_role(role_name, resource, true)
      end

      private

      def accessible_roles_for(resource, inheritnce)
        accessible_roles = if inheritnce
                             resource_and_inheritence_roles(resource)
                           else
                             resource_roles(resource).order('level desc')
                           end

        accessible_roles.present? ? accessible_roles : descendant_role(resource)
      end

      def resource_and_inheritence_roles(resource)
        hierarchy_ids = resource.hierarchy.ancestors.select(:id)
        Monarchy.role_class.where(id:
                      Monarchy.role_class.joins(:members).where('monarchy_members.user_id': id)
                      .where('monarchy_roles.inherited': 't', 'monarchy_members.hierarchy_id': hierarchy_ids)
                      .select(:inherited_role_id))
                .union(resource_roles(resource))
                .distinct
      end

      def resource_roles(resource)
        Monarchy.role_class.joins(:members)
                .where('monarchy_members.hierarchy_id': resource.hierarchy.id, 'monarchy_members.user_id': id)
                .distinct
      end

      def descendant_role(resource)
        descendant_ids = resource.hierarchy.descendant_ids
        children_access = members_for(descendant_ids).present?
        children_access ? Monarchy.role_class.where(id: default_role) : Monarchy.role_class.none
      end

      def revoking_role(role_name, resource, force = false)
        member_roles = member_for(resource).try(:members_roles)
        return 0 if member_roles.nil?

        return revoke_access(resource) if last_role?(member_roles, role_name) && force
        member_roles.joins(:role).where(monarchy_roles: { name: role_name }).delete_all
      end

      def grant_or_create_member(role_name, resource)
        role = Monarchy.role_class.find_by(name: role_name)
        raise Monarchy::Exceptions::RoleNotExist, role_name unless role

        member = member_for(resource)
        if member
          Monarchy::MembersRole.create(member: member, role: role)
        else
          member = Monarchy.member_class.create(user: self, hierarchy: resource.hierarchy, roles: [role])
        end

        member
      end

      def members_for(hierarchy_ids)
        Monarchy.member_class.where(hierarchy_id: hierarchy_ids, user_id: id)
      end

      def default_role
        @default_role ||= Monarchy.role_class.find_by(name: Monarchy.configuration.default_role.name)
      end

      def last_role?(member_roles, role_name = nil)
        role_name ||= default_role.name
        member_roles.count == 1 && member_roles.first.role.name == role_name.to_s
      end

      def default_role?(role_name)
        default_role.name.to_s == role_name.to_s
      end
    end
  end
end

ActiveRecord::Base.send :include, Monarchy::ActsAsUser
