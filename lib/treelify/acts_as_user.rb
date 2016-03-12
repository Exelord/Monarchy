# frozen_string_literal: true
module Treelify
  module ActsAsUser
    extend ActiveSupport::Concern

    module ClassMethods
      def acts_as_user
        has_many :members

        include Treelify::ActsAsUser::InstanceMethods
      end
    end

    module InstanceMethods
      def role_for(resource)
        ansestors_ids = resource.hierarchy.self_and_ancestors_ids
        Role.joins(:members)
            .where("((roles.inherited = 't' "\
                   "AND members.hierarchy_id IN (#{ansestors_ids.join(',')})) "\
                   "OR (members.hierarchy_id = #{resource.hierarchy.id})) AND members.user_id = #{id}")
            .order(level: :desc).first
      end

      def grant(role_name, resource)
        ActiveRecord::Base.transaction do
          Member.create(build_members(resource.hierarchy.memberless_ancestors_for(self)))
          grant_or_create_member(role_name, resource)
        end
      end

      def member_for(resource)
        resource.hierarchy.members.where("members.user_id": id).first
      end

      def revoke(resource)
        self_and_descendant_ids = resource.hierarchy.self_and_descendant_ids

        ActiveRecord::Base.transaction do
          members_role_for(self_and_descendant_ids).destroy_all
          try_revoke_ancestors_for(resource)
        end
      end

      private

      def grant_or_create_member(role_name, resource)
        role = Role.find_by(name: role_name)
        member = member_for(resource)

        if member
          MembersRole.create(member: member, role: role)
        else
          member = Member.create(build_members(resource.hierarchy, [role])).first
        end

        member
      end

      def build_members(hierarchies, roles = [])
        Array(hierarchies).map { |hierarchy| { user: self, hierarchy: hierarchy, roles: roles } }
      end

      def default_role?(role)
        role.name == Treelify.configuration.default_role.name.to_s
      end

      def members_role_for(hierarchy_ids)
        MembersRole.joins(:member).where("members.hierarchy_id": hierarchy_ids, "members.user_id": id)
      end

      def try_revoke_ancestors_for(resource)
        resource.hierarchy.ancestors.each do |hierarchy|
          member_roles = members_role_for(hierarchy.self_and_descendant_ids)
          only_guest = member_roles.count == 1 && default_role?(member_roles.first.role)
          only_guest ? member_roles.destroy_all : break
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, Treelify::ActsAsUser
