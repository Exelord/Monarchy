# frozen_string_literal: true
FactoryGirl.define do
  factory :hierarchy, class: Monarchy::Hierarchy do
    before(:create) do |hierarchy|
      unless hierarchy.resource
        Project.skip_callback(:create, :after, :ensure_hierarchy)
        hierarchy.resource = Project.create
        Project.set_callback(:create, :after, :ensure_hierarchy)
      end
    end
  end
end
