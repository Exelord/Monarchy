# frozen_string_literal: true
module Monarchy
  module Exceptions
    class Error < StandardError; end

    class RoleNotExist < Error
      def initialize(role_name)
        @role_name = role_name
      end

      def message
        "Role '#{@role_name}' does not exist"
      end
    end
  end
end
