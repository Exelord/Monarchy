# frozen_string_literal: true
module Monarchy
  module ActsAsHierarchy
    extend ActiveSupport::Concern

    module ClassMethods
      def acts_as_hierarchy
        has_closure_tree dependent: :destroy

        has_many :members, class_name: 'Monarchy::Member'
        belongs_to :resource, polymorphic: true, dependent: :destroy

        validates :resource, presence: true

        include Monarchy::ActsAsHierarchy::InstanceMethods
      end
    end

    module InstanceMethods
    end
  end
end

ActiveRecord::Base.send :include, Monarchy::ActsAsHierarchy
