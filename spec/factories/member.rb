# frozen_string_literal: true
FactoryGirl.define do
  factory :member, class: Monarchy::Member do
    user
    hierarchy
  end
end
