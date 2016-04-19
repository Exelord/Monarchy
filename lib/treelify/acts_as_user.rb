# frozen_string_literal: true
module Treelify
  module ActsAsUser
    extend ActiveSupport::Concern

    module ClassMethods
      def acts_as_user
        has_many :members, class_name: 'Treelify::Member'

        include Treelify::ActsAsUser::InstanceMethods
      end
    end

    module InstanceMethods
      def role_for(resource)
        ansestors_ids = resource.hierarchy.self_and_ancestors_ids
        Treelify::Role.joins(:members)
                      .where("((treelify_roles.inherited = 't' "\
                   "AND treelify_members.hierarchy_id IN (#{ansestors_ids.join(',')})) "\
                   "OR (treelify_members.hierarchy_id = #{resource.hierarchy.id})) "\
                   "AND treelify_members.user_id = #{id}")
                      .order(level: :desc).first
      end

      def grant(role_name, resource)
        ActiveRecord::Base.transaction do
          Treelify::Member.create(build_members(resource.hierarchy.memberless_ancestors_for(self)))
          grant_or_create_member(role_name, resource)
        end
      end

      def member_for(resource)
        resource.hierarchy.members.where("treelify_members.user_id": id).first
      end

      def revoke_access(resource)
        self_and_descendant_ids = resource.hierarchy.self_and_descendant_ids

        ActiveRecord::Base.transaction do
          members_roles_for(self_and_descendant_ids).destroy_all
          try_revoke_ancestors_for(resource)
        end
      end

      def revoke_role(role_name, resource)
        members_roles = member_for(resource).members_roles

        if only_this_role(members_roles, role_name)
          revoke_access(resource)
        else
          members_roles.joins(:role).where("treelify_roles.name": role_name).destroy_all
        end
      end

      private

      def grant_or_create_member(role_name, resource)
        role = Treelify::Role.find_by(name: role_name)
        member = member_for(resource)

        if member
          Treelify::MembersRole.create(member: member, role: role)
        else
          member = Treelify::Member.create(build_members(resource.hierarchy, [role])).first
        end

        member
      end

      def build_members(hierarchies, roles = [])
        Array(hierarchies).map { |hierarchy| { user: self, hierarchy: hierarchy, roles: roles } }
      end

      def equal_role_name?(role, role_name)
        role.name == role_name.to_s
      end

      def only_this_role(members_roles, role_name = nil)
        role_name ||= Treelify.configuration.default_role.name.to_s
        members_roles.count == 1 && equal_role_name?(members_roles.first.role, role_name)
      end

      def members_roles_for(hierarchy_ids)
        Treelify::MembersRole.joins(:member)
                             .where("treelify_members.hierarchy_id": hierarchy_ids, "treelify_members.user_id": id)
      end

      def try_revoke_ancestors_for(resource)
        resource.hierarchy.ancestors.each do |hierarchy|
          members_roles = members_roles_for(hierarchy.self_and_descendant_ids)
          only_this_role(members_roles) ? members_roles.destroy_all : break
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, Treelify::ActsAsUser
