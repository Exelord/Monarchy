# frozen_string_literal: true
module Monarchy
  module Validators
    class << self
      def role_name(role_name)
        role = Monarchy.role_class.find_by(name: role_name)
        role || raise(Monarchy::Exceptions::RoleNotExist, role_name)
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
    end
  end
end
