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
      def role_for(resource)
        accessible_roles_in(resource).first
      end

      def roles_for(resource)
        roles = accessible_roles_in(resource)
        grouped_roles = roles.group_by(&:level)
        key = grouped_roles.keys.first
        grouped_roles[key]
      end

      def grant(role_name, resource)
        ActiveRecord::Base.transaction do
          Monarchy::Member.create(build_members(resource.hierarchy.memberless_ancestors_for(self)))
          grant_or_create_member(role_name, resource)
        end
      end

      def member_for(resource)
        resource.hierarchy.members.where(monarchy_members: { user_id: id }).first
      end

      def revoke_access(resource)
        self_and_descendant_ids = resource.hierarchy.self_and_descendant_ids

        ActiveRecord::Base.transaction do
          members_roles_for(self_and_descendant_ids).destroy_all
          try_revoke_ancestors_for(resource)
        end
      end

      def revoke_role(role_name, resource)
        revoking_role(role_name, resource)
      end

      def revoke_role!(role_name, resource)
        revoking_role(role_name, resource, true)
      end

      private

      def accessible_roles_in(resource)
        ancestors_ids = resource.hierarchy.self_and_ancestors_ids
        Monarchy::Role.joins(:members)
                      .where("((monarchy_roles.inherited = 't' "\
                       "AND monarchy_members.hierarchy_id IN (#{ancestors_ids.join(',')})) "\
                       "OR (monarchy_members.hierarchy_id = #{resource.hierarchy.id})) "\
                       "AND monarchy_members.user_id = #{id}")
                      .order(level: :desc)
      end

      def revoking_role(role_name, resource, force = false)
        member = member_for(resource)
        members_roles = member.members_roles

        if only_this_role(members_roles, role_name)
          return revoke_access(resource) if force
          grant_default_role unless default_role?(role_name)
        else
          members_roles.joins(:role).where(monarchy_roles: { name: role_name }).destroy_all
        end
      end

      def grant_or_create_member(role_name, resource)
        role = Monarchy::Role.find_by(name: role_name)
        member = member_for(resource)

        if member
          Monarchy::MembersRole.create(member: member, role: role)
        else
          member = Monarchy::Member.create(build_members(resource.hierarchy, [role])).first
        end

        member
      end

      def try_revoke_ancestors_for(resource)
        resource.hierarchy.ancestors.each do |hierarchy|
          members_roles = members_roles_for(hierarchy.self_and_descendant_ids)
          only_this_role(members_roles) ? members_roles.destroy_all : break
        end
      end

      # functions

      def grant_default_role(member)
        Monarchy::MembersRole.create(member: member, role: default_role)
      end

      def members_roles_for(hierarchy_ids)
        Monarchy::MembersRole.joins(:member)
                             .where(monarchy_members: { hierarchy_id: hierarchy_ids, user_id: id })
      end

      def build_members(hierarchies, roles = [])
        Array(hierarchies).map { |hierarchy| { user: self, hierarchy: hierarchy, roles: roles } }
      end

      def default_role
        @default_role ||= Monarchy::Role.find_by(name: Monarchy.configuration.default_role.name)
      end

      # helpers

      def only_this_role(members_roles, role_name = nil)
        role_name ||= default_role.name
        members_roles.count == 1 && equal_role_name?(members_roles.first.role, role_name)
      end

      def equal_role_name?(role, role_name)
        role.name == role_name.to_s
      end

      def default_role?(role_name)
        default_role.name.to_s == role_name.to_s
      end
    end
  end
end

ActiveRecord::Base.send :include, Monarchy::ActsAsUser
