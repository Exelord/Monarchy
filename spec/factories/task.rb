# frozen_string_literal: true

FactoryGirl.define do
  factory :task do
    name FFaker::Product.product
  end
end
