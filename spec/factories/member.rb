# frozen_string_literal: true

FactoryGirl.define do
  factory :member, class: Member do
    user
    association :resource, factory: %i[project memo].sample
  end
end
