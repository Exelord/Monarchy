FactoryGirl.define do
  factory :hierarchy do
    association :resource, factory: [:project, :memo].sample
  end
end
