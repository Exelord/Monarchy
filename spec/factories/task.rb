# frozen_string_literal: true

FactoryBot.define do
  factory :task do
    name { FFaker::Product.product }
  end
end
