# frozen_string_literal: true
module Monarchy
  module ActsAsUser
    extend ActiveSupport::Concern

    module ClassMethods
      def acts_as_user
        has_many :members, class_name: 'Monarchy::Member'

        include Monarchy::ActsAsUser::InstanceMethods
      end
    end

    module InstanceMethods
      def roles_for(resource)
        accessible_roles_for(resource).group_by(&:level).values.first
      end

      def member_for(resource)
        resource.hierarchy.members.where(monarchy_members: { user_id: id }).first
      end

      def grant(role_name, resource)
        ActiveRecord::Base.transaction do
          grant_or_create_member(role_name, resource)
        end
      end

      def revoke_access(resource)
        self_and_descendant_ids = resource.hierarchy.self_and_descendant_ids
        members_for(self_and_descendant_ids).destroy_all
      end

      def revoke_role(role_name, resource)
        revoking_role(role_name, resource)
      end

      def revoke_role!(role_name, resource)
        revoking_role(role_name, resource, true)
      end

      private

      def accessible_roles_for(resource)
        ancestors_ids = resource.hierarchy.self_and_ancestors_ids
        self_or_inherited_roles = Monarchy::Role.joins(:members)
                                                .where("((monarchy_roles.inherited = 't' "\
                       "AND monarchy_members.hierarchy_id IN (#{ancestors_ids.join(',')})) "\
                       "OR (monarchy_members.hierarchy_id = #{resource.hierarchy.id})) "\
                       "AND monarchy_members.user_id = #{id}")
                                                .distinct.order(level: :desc)

        self_or_inherited_roles.present? ? self_or_inherited_roles : descendant_role(resource)
      end

      def descendant_role(resource)
        descendant_ids = resource.hierarchy.descendant_ids
        children_access = members_for(descendant_ids).present?
        children_access ? [default_role] : []
      end

      def revoking_role(role_name, resource, force = false)
        member = member_for(resource)
        member_roles = member.members_roles

        return revoke_access(resource) if only_this_role(member_roles, role_name) && force
        member_roles.joins(:role).where(monarchy_roles: { name: role_name }).destroy_all
      end

      def grant_or_create_member(role_name, resource)
        role = Monarchy::Role.find_by(name: role_name)
        member = member_for(resource)

        if member
          Monarchy::MembersRole.create(member: member, role: role)
        else
          member = Monarchy::Member.create(user: self, hierarchy: resource.hierarchy, roles: [role])
        end

        member
      end

      def members_for(hierarchy_ids)
        Monarchy::Member.where(hierarchy_id: hierarchy_ids, user_id: id)
      end

      def default_role
        @default_role ||= Monarchy::Role.find_by(name: Monarchy.configuration.default_role.name)
      end

      def only_this_role(members_roles, role_name = nil)
        role_name ||= default_role.name
        members_roles.count == 1 && members_roles.first.role.name == role_name.to_s
      end

      def default_role?(role_name)
        default_role.name.to_s == role_name.to_s
      end
    end
  end
end

ActiveRecord::Base.send :include, Monarchy::ActsAsUser
