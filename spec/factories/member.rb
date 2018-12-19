# frozen_string_literal: true

FactoryBot.define do
  factory :member, class: Member do
    user
    association :resource, factory: %i[project memo].sample
  end
end
