# frozen_string_literal: true
FactoryGirl.define do
<<<<<<< Updated upstream
  factory :hierarchy, class: Monarchy::Hierarchy do
=======
<<<<<<< Updated upstream
  factory :hierarchy do
=======
  factory :hierarchy, class: Monarchy::Hierarchy do
>>>>>>> Stashed changes
>>>>>>> Stashed changes
    association :resource, factory: [:project, :memo].sample
  end
end
