FactoryGirl.define do
  factory :role do
    name FFaker::Job.title
    level Random.rand(0..5)
  end
end
