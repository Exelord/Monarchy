# frozen_string_literal: true
FactoryGirl.define do
<<<<<<< Updated upstream
  factory :role, class: Monarchy::Role do
=======
<<<<<<< Updated upstream
  factory :role do
=======
  factory :role, class: Monarchy::Role do
>>>>>>> Stashed changes
>>>>>>> Stashed changes
    name FFaker::Job.title
    level Random.rand(0..5)
    inherited true
  end
end
