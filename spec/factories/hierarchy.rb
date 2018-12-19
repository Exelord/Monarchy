# frozen_string_literal: true

FactoryBot.define do
  factory :hierarchy, class: Monarchy::Hierarchy do
    before(:create) do |hierarchy|
      unless hierarchy.resource
        Project.automatic_hierarchy = false
        hierarchy.resource = Project.create
        Project.automatic_hierarchy = true
      end
    end
  end
end
