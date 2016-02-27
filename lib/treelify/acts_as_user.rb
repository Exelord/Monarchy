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
            .where("((roles.inherited = 't' AND members.hierarchy_id IN (#{ansestors_ids.join(',')})) OR (members.hierarchy_id = #{resource.hierarchy.id})) AND members.user_id = #{id}")
            .order(level: :desc).first
      end

      def grant(role_name, resource)
        ActiveRecord::Base.transaction do
          Member.create(build_members(resource.hierarchy.empty_ancestors_for(self)))
          member = grant_or_create_member(role_name, resource)
        end
      end

      def member_for(resource)
        resource.hierarchy.members.where("members.user_id": id).first
      end

      private

      def grant_or_create_member(role_name, resource)
        role = Role.find_by(name: role_name)
        member = member_for(resource)

        if member
          MembersRole.create(member: member, role: role)
        else
          member = Member.create(build_members(resource.hierarchy, [role]))
        end

        member
      end

      def build_members(hierarchies, roles=[])
        Array(hierarchies).map { |hierarchy| { user: self, hierarchy: hierarchy, roles: roles} }
      end
    end
  end
end

ActiveRecord::Base.send :include, Treelify::ActsAsUser
