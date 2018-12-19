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

      def role_names(*role_names)
        role_names.flatten!
        roles = Monarchy.role_class.where(name: role_names)
        wrong_names = role_names.map(&:to_s) - roles.map(&:name)
        wrong_names.each { |name| raise(Monarchy::Exceptions::RoleNotExist, name) }
        roles
      end

      def resource(resource, allow_nil = false, persistance = true)
        raise Monarchy::Exceptions::ResourceIsNil if !resource && !allow_nil

        model = check_model_class(resource, 'ModelNotResource') do
          resource.class.try(:acting_as_resource)
        end

        persistance && resource && !resource.persisted? ? raise(Monarchy::Exceptions::ResourceNotPersist) : model
      end

      def user(user, allow_nil = false)
        raise Monarchy::Exceptions::UserIsNil if !user && !allow_nil

        model_is_class(user, Monarchy.user_class, 'ModelNotUser')
      end

      def member(member, allow_nil = false)
        raise Monarchy::Exceptions::MemberIsNil if !member && !allow_nil

        model_is_class(member, Monarchy.member_class, 'ModelNotMember')
      end

      def role(role, allow_nil = false)
        raise Monarchy::Exceptions::RoleIsNil if !role && !allow_nil

        model_is_class(role, Monarchy.role_class, 'ModelNotRole')
      end

      private

      def check_model_class(model, exception_class)
        if yield
          model
        elsif model
          raise "Monarchy::Exceptions::#{exception_class}".constantize, model
        end
      end

      def model_is_class(model, klass, exception_class)
        check_model_class(model, exception_class) do
          model.is_a?(klass)
        end
      end
    end
  end
end
