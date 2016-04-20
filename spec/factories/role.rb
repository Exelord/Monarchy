# frozen_string_literal: true
FactoryGirl.define do
  factory :role, class: Monarchy::Role do
    name FFaker::Job.title
    level Random.rand(0..5)
    inherited true
  end
end
