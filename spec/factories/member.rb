# frozen_string_literal: true
FactoryGirl.define do
  factory :member, class: Treelify::Member do
    user
    hierarchy
  end
end
