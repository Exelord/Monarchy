# frozen_string_literal: true

FactoryGirl.define do
  factory :memo do
    name FFaker::Product.product
  end
end
