FactoryBot.define do
  factory :car do
    association :vendor
    brand { Car::BRAND_LOGOS.sample[:name] }
    model { Faker::Vehicle.model }
    year { rand(2018..2024) }
    category { %w[Sedan SUV Luxury Sports Economy].sample }
    daily_price { rand(50..500) }
    weekly_price { daily_price * 6 }
    monthly_price { daily_price * 25 }
    status { 'available' }
    insurance_policy { Faker::Alphanumeric.alpha(number: 10).upcase }

    after(:build) do |car|
      car.images.attach(
        io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'test_image.jpg')),
        filename: 'test_car.jpg',
        content_type: 'image/jpeg'
      ) unless car.images.attached?
    end

    trait :available do
      status { 'available' }
    end

    trait :unavailable do
      status { 'unavailable' }
    end

    trait :with_features do
      air_conditioning { true }
      gps { true }
      bluetooth { true }
      sunroof { false }
    end

    trait :with_bookings do
      after(:create) do |car|
        create_list(:booking, 2, car: car)
      end
    end

    trait :with_approved_document do
      after(:create) do |car|
        create(:car_document, :approved, car: car)
      end
    end

    trait :luxury do
      category { 'Luxury' }
      brand { 'Rolls Royce' }
      daily_price { rand(800..2000) }
    end

    trait :with_driver do
      with_driver { true }
    end
  end
end
