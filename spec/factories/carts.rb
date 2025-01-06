FactoryBot.define do
  factory :cart do
    total_price { 0.0 }
    status { 'open' }
    last_interaction_at { Time.current }

    trait :abandoned do
      status { 'abandoned' }
      last_interaction_at { 8.days.ago }
    end
  end
end
