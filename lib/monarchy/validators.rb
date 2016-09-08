# frozen_string_literal: true
module Monarchy
  module Validators
    class << self
      def last_role?(member, role)
        member(member)
        role(role)
        (member.roles - [role]).empty?
      end

      def default_role?(resource, role)
        resource(resource)
        role(role)

        role == resource.class.default_role
      end

      def role_name(role_name)
        role = Monarchy.role_class.find_by(name: role_name)
        role || raise(Monarchy::Exceptions::RoleNotExist, role_name)
      end

      def role_names(role_names)
        roles = Monarchy.role_class.where(name: role_names)
        wrong_names = role_names.map(&:to_s) - roles.map(&:name)
        wrong_names.each { |name| raise(Monarchy::Exceptions::RoleNotExist, name) }
        roles
      end

      def resource(resource, allow_nil = false)
        raise Monarchy::Exceptions::ResourceIsNil if !resource && !allow_nil

        if resource
          true_resource = resource.class.try(:acting_as_resource)
          raise Monarchy::Exceptions::ModelNotResource, resource unless true_resource
        end
      end

      def user(user, allow_nil = false)
        raise Monarchy::Exceptions::UserIsNil if !user && !allow_nil

        if user
          true_user = user.is_a?(Monarchy.user_class)
          raise Monarchy::Exceptions::ModelNotUser, user unless true_user
        end
      end

      def member(member, allow_nil = false)
        raise Monarchy::Exceptions::MemberIsNil if !member && !allow_nil

        if member
          true_member = member.is_a?(Monarchy.member_class)
          raise Monarchy::Exceptions::ModelNotMember, member unless true_member
        end
      end

      def role(role, allow_nil = false)
        raise Monarchy::Exceptions::RoleIsNil if !role && !allow_nil

        if role
          true_role = role.is_a?(Monarchy.role_class)
          raise Monarchy::Exceptions::ModelNotRole, role unless true_role
        end
      end
    end
  end
end
