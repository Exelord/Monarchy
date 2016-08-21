module Monarchy
  module Validators
    class << self
      def role_name(role_name)
        role = Monarchy.role_class.find_by(name: role_name)
        role || raise(Monarchy::Exceptions::RoleNotExist, role_name)
      end

      def resource(resource)
        raise Monarchy::Exceptions::ResourceIsNil unless resource

        true_resource = resource.class.try(:acting_as_resource)
        raise Monarchy::Exceptions::ModelNotResource, resource unless true_resource
      end
    end
  end
end
