FactoryBot.define do
  factory :activity do
    association :subject, factory: :user
    action { Activity::ACTIONS.sample }
    description { Faker::Lorem.sentence }
    metadata { { key: 'value' }.to_json }

    trait :for_user do
      association :user
      vendor { nil }
    end

    trait :for_vendor do
      association :vendor
      user { nil }
    end

    trait :booking_created do
      action { 'booking_created' }
      association :subject, factory: :booking
    end

    trait :document_uploaded do
      action { 'document_uploaded' }
      association :subject, factory: :document
    end

    trait :car_added do
      action { 'car_added' }
      association :subject, factory: :car
    end
  end
end
