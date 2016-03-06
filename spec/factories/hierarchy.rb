# frozen_string_literal: true
FactoryGirl.define do
  factory :hierarchy do
    association :resource, factory: [:project, :memo].sample
  end
end
