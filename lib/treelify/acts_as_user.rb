module Treelify
  module ActsAsUser
    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods
      def acts_as_user
        has_many :members

        include Treelify::ActsAsUser::LocalInstanceMethods
      end
    end

    module LocalInstanceMethods
      def role_for(resource)
        Role.joins(:members).where(members: { hierarchy_id: resource.hierarchy.self_and_ancestors_ids, user_id: id}).order(level: :desc).first
      end
    end

  end
end

ActiveRecord::Base.send :include, Treelify::ActsAsUser
