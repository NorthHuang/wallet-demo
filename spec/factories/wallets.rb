FactoryBot.define do
  factory :wallet do
    balance { 100.12 }
    association :user
  end
end
