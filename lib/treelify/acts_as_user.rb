# frozen_string_literal: true
module Monarchy
  module ActsAsUser
    extend ActiveSupport::Concern

    module ClassMethods
      def acts_as_user
<<<<<<< Updated upstream
        has_many :members, class_name: 'Monarchy::Member'
=======
<<<<<<< Updated upstream
        has_many :members
=======
        has_many :members, class_name: 'Monarchy::Member'
>>>>>>> Stashed changes
>>>>>>> Stashed changes

        include Monarchy::ActsAsUser::InstanceMethods
      end
    end

    module InstanceMethods
      def role_for(resource)
<<<<<<< Updated upstream
        ancestors_ids = resource.hierarchy.self_and_ancestors_ids
        Monarchy::Role.joins(:members)
                      .where("((tonarchy_roles.inherited = 't' "\
                       "AND tonarchy_members.hierarchy_id IN (#{ancestors_ids.join(',')})) "\
                       "OR (tonarchy_members.hierarchy_id = #{resource.hierarchy.id})) "\
                       "AND tonarchy_members.user_id = #{id}")
                      .order(level: :desc).first
=======
<<<<<<< Updated upstream
        ansestors_ids = resource.hierarchy.self_and_ancestors_ids
        Role.joins(:members)
            .where("((roles.inherited = 't' "\
                   "AND members.hierarchy_id IN (#{ansestors_ids.join(',')})) "\
                   "OR (members.hierarchy_id = #{resource.hierarchy.id})) AND members.user_id = #{id}")
            .order(level: :desc).first
=======
        ancestors_ids = resource.hierarchy.self_and_ancestors_ids
        Monarchy::Role.joins(:members)
                      .where("((monarchy_roles.inherited = 't' "\
                       "AND monarchy_members.hierarchy_id IN (#{ancestors_ids.join(',')})) "\
                       "OR (monarchy_members.hierarchy_id = #{resource.hierarchy.id})) "\
                       "AND monarchy_members.user_id = #{id}")
                      .order(level: :desc).first
>>>>>>> Stashed changes
>>>>>>> Stashed changes
      end

      def grant(role_name, resource)
        ActiveRecord::Base.transaction do
<<<<<<< Updated upstream
          Monarchy::Member.create(build_members(resource.hierarchy.memberless_ancestors_for(self)))
=======
<<<<<<< Updated upstream
          Member.create(build_members(resource.hierarchy.memberless_ancestors_for(self)))
=======
          Monarchy::Member.create(build_members(resource.hierarchy.memberless_ancestors_for(self)))
>>>>>>> Stashed changes
>>>>>>> Stashed changes
          grant_or_create_member(role_name, resource)
        end
      end

      def member_for(resource)
<<<<<<< Updated upstream
        resource.hierarchy.members.where("tonarchy_members.user_id": id).first
=======
<<<<<<< Updated upstream
        resource.hierarchy.members.where("members.user_id": id).first
=======
        resource.hierarchy.members.where("monarchy_members.user_id": id).first
>>>>>>> Stashed changes
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
          members_roles.joins(:role).where("tonarchy_roles.name": role_name).destroy_all
=======
<<<<<<< Updated upstream
          members_roles.joins(:role).where("roles.name": role_name).destroy_all
=======
          members_roles.joins(:role).where("monarchy_roles.name": role_name).destroy_all
>>>>>>> Stashed changes
>>>>>>> Stashed changes
        end
      end

      private

      def grant_or_create_member(role_name, resource)
<<<<<<< Updated upstream
        role = Monarchy::Role.find_by(name: role_name)
=======
<<<<<<< Updated upstream
        role = Role.find_by(name: role_name)
>>>>>>> Stashed changes
        member = member_for(resource)

        if member
          Monarchy::MembersRole.create(member: member, role: role)
        else
<<<<<<< Updated upstream
          member = Monarchy::Member.create(build_members(resource.hierarchy, [role])).first
=======
          member = Member.create(build_members(resource.hierarchy, [role])).first
=======
        role = Monarchy::Role.find_by(name: role_name)
        member = member_for(resource)

        if member
          Monarchy::MembersRole.create(member: member, role: role)
        else
          member = Monarchy::Member.create(build_members(resource.hierarchy, [role])).first
>>>>>>> Stashed changes
>>>>>>> Stashed changes
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
        role_name ||= Monarchy.configuration.default_role.name.to_s
        members_roles.count == 1 && equal_role_name?(members_roles.first.role, role_name)
      end

      def members_roles_for(hierarchy_ids)
<<<<<<< Updated upstream
        Monarchy::MembersRole.joins(:member)
                             .where(tonarchy_members: { hierarchy_id: hierarchy_ids, user_id: id })
=======
<<<<<<< Updated upstream
        MembersRole.joins(:member).where("members.hierarchy_id": hierarchy_ids, "members.user_id": id)
=======
        Monarchy::MembersRole.joins(:member)
                             .where(monarchy_members: { hierarchy_id: hierarchy_ids, user_id: id })
>>>>>>> Stashed changes
>>>>>>> Stashed changes
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

ActiveRecord::Base.send :include, Monarchy::ActsAsUser
