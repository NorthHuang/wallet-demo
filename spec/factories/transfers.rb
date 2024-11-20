FactoryBot.define do
  factory :transfer do
    association :from_user, factory: :user
    association :to_user, factory: :user
    amount { 100.50 }
  end
end
