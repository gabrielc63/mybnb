FactoryBot.define do
  factory :review do
    rating { 1 }
    comment { "MyText" }
    user { nil }
    listing { nil }
  end
end
