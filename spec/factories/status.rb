# frozen_string_literal: true
FactoryGirl.define do
  factory :status do
    name FFaker::Product.product
  end
end
