FactoryBot.define do
  factory :listing do
    association :user
    title { Faker::House.room + ' in ' + Faker::Address.city }
    description { Faker::Lorem.paragraph(sentence_count: 3) }
    price_per_night { Faker::Number.between(from: 50, to: 1000) }
    bedrooms { Faker::Number.between(from: 1, to: 5) }
    bathrooms { Faker::Number.between(from: 1, to: 3) }
    max_guests { Faker::Number.between(from: 1, to: 10) }
    property_type { Listing.property_types.keys.sample }
    address { Faker::Address.full_address }
    latitude { Faker::Address.latitude }
    longitude { Faker::Address.longitude }

    trait :with_photos do
      after(:build) do |listing|
        2.times do
          listing.photos.attach(
            io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'test_image.jpg')),
            filename: 'test_image.jpg',
            content_type: 'image/jpeg'
          )
        end
      end
    end
  end
end
