# frozen_string_literal: true
FactoryGirl.define do
  factory :hierarchy, class: Treelify::Hierarchy do
    association :resource, factory: [:project, :memo].sample
  end
end
