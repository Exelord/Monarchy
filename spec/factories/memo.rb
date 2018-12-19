# frozen_string_literal: true

FactoryBot.define do
  factory :memo do
    name { FFaker::Product.product }
  end
end
