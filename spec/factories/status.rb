# frozen_string_literal: true

FactoryBot.define do
  factory :status do
    name { FFaker::Product.product }
  end
end
