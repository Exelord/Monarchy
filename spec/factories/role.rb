FactoryGirl.define do
  factory :role do
    name FFaker::Job.title
    level rand(0..5)
  end
end
