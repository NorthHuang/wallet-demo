FactoryBot.define do
  factory :withdrawal do
    amount { 100.0 }
    platform { 'visa' }
    order_no { "WITH#{Faker::Number.unique.number(digits: 5)}" }
    status { 'pending' }
    association :user
  end
end
