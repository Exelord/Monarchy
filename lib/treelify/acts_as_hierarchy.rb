module Treelify
  module ActsAsHierarchy
    extend ActiveSupport::Concern

    module ClassMethods
      def acts_as_hierarchy
        has_closure_tree dependent: :destroy
        belongs_to :parent, class_name: Hierarchy
        has_many :members
        belongs_to :resource, polymorphic: true

        validates :resource, presence: true
      end
    end
  end
end

ActiveRecord::Base.send :include, Treelify::ActsAsHierarchy
