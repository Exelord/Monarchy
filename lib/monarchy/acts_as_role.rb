# frozen_string_literal: true

module Monarchy
  module ActsAsRole
    extend ActiveSupport::Concern

    module ClassMethods
      def acts_as_role
        self.table_name = 'monarchy_roles'

        has_many :members_roles, dependent: :destroy, class_name: 'Monarchy::MembersRole'
        has_many :members, through: :members_roles, class_name: "::#{Monarchy.member_class}"

        belongs_to :inherited_role, class_name: "::#{Monarchy.role_class}"

        after_create :default_inherited_role

        validates :name, presence: true
        validates :level, presence: true

        include Monarchy::ActsAsRole::InstanceMethods
      end
    end

    module InstanceMethods
      private

      def default_inherited_role
        update(inherited_role_id: id) unless inherited_role
      end
    end
  end
end

ActiveRecord::Base.send :include, Monarchy::ActsAsRole
