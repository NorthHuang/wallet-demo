FactoryBot.define do
  factory :event do
    association :user
    association :eventable
  end
end
