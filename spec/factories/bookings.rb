FactoryBot.define do
  factory :booking do
    association :user
    association :listing
    start_date { 1.week.from_now.to_date }
    end_date { 2.weeks.from_now.to_date }
    guests_amount { 2 }
    special_requests { "Early check-in please" }
    status { :pending }
    final_price { 500.00 }

    trait :confirmed do
      status { :confirmed }
    end

    trait :cancelled do
      status { :cancelled }
    end

    trait :completed do
      status { :completed }
      start_date { 2.weeks.ago.to_date }
      end_date { 1.week.ago.to_date }
    end

    trait :rejected do
      status { :rejected }
    end

    trait :past_dates do
      start_date { 2.weeks.ago.to_date }
      end_date { 1.week.ago.to_date }
    end
  end
end
