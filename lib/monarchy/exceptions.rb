# frozen_string_literal: true
module Monarchy
  module Exceptions
    class Error < StandardError; end

    class ClassNotDefined < Error
      def initialize(class_name)
        @class_name = class_name
      end

      def message
        "#{@class_name} class has to be initialized or exist!"
      end
    end

    class ConfigNotDefined < Error
      def initialize(property)
        @property = property
      end

      def message
        "Monarchy requires a #{@property} to be configured!"
      end
    end

    class RoleNotExist < Error
      def initialize(role_name)
        @role_name = role_name
      end

      def message
        "Role '#{@role_name}' does not exist"
      end
    end

    class ModelNotResource < Error
      def initialize(resource)
        @resource = resource
      end

      def message
        "Model '#{@resource.class}' is not acting as resource!"
      end
    end

    class ModelNotMember < Error
      def initialize(member)
        @member = member
      end

      def message
        "Model '#{@member.class}' is not acting as member!"
      end
    end

    class ModelNotRole < Error
      def initialize(role)
        @role = role
      end

      def message
        "Model '#{@role.class}' is not acting as role!"
      end
    end

    class ModelNotUser < Error
      def initialize(user)
        @user = user
      end

      def message
        "Model '#{@user.class}' is not acting as user!"
      end
    end

    class RoleNotRevokable < Error
      def message
        "Can not revoke default role when no more roles exists! \
          (Use 'revoke_role!' if you know what you are doing )"
      end
    end

    class ResourceIsNil < Error
      def message
        'Resource can NOT be nil!'
      end
    end

    class UserIsNil < Error
      def message
        'User can NOT be nil!'
      end
    end

    class MemberIsNil < Error
      def message
        'Member can NOT be nil!'
      end
    end

    class RoleIsNil < Error
      def message
        'Role can NOT be nil!'
      end
    end

    class ResourceNotPersist < Error
      def message
        'Resource has to persisted!'
      end
    end
  end
end
