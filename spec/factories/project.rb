# frozen_string_literal: true
FactoryGirl.define do
  factory :project do
    name FFaker::Product.product
  end
end
