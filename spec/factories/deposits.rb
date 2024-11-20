FactoryBot.define do
  factory :deposit do
    amount { 200.0 }
    platform { 'visa' }
    order_no { "DEP#{Faker::Number.unique.number(digits: 5)}" }
    association :user
  end
end
