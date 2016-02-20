module Treelify
  module ActsAsHierarchy
    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods
      def acts_as_hierarchy
        has_many :members
        belongs_to :resource, polymorphic: true

        validates :reosurce, presence: true

        include Treelify::ActsAsHierarchy::LocalInstanceMethods
      end
    end

    module LocalInstanceMethods
    end
  end
end

ActiveRecord::Base.send :include, Treelify::ActsAsHierarchy
