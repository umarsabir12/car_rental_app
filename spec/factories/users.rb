FactoryBot.define do
  factory :user do
    sequence(:first_name) { |n| "#{Faker::Name.first_name}#{n}" }
    sequence(:last_name) { |n| "#{Faker::Name.last_name}#{n}" }
    email { Faker::Internet.unique.email }
    password { 'Password123!' }
    password_confirmation { 'Password123!' }
    phone { '+971501234567' }
    nationality { %w[resident tourist].sample }
    terms_accepted { true }
    sequence(:whatsapp_number) { |n| "+97150#{sprintf('%07d', n)}" }

    trait :resident do
      nationality { 'resident' }
    end

    trait :tourist do
      nationality { 'tourist' }
    end

    trait :with_documents do
      # Documents are automatically created by after_create callback
      # No need to call create_documents again
    end

    trait :with_approved_documents do
      after(:create) do |user|
        # Documents are automatically created by after_create callback
        user.documents.update_all(status: 'approved')
      end
    end

    trait :with_bookings do
      after(:create) do |user|
        create_list(:booking, 3, user: user)
      end
    end

    trait :omniauth do
      provider { 'google_oauth2' }
      uid { Faker::Number.number(digits: 10).to_s }
    end

    trait :without_whatsapp do
      whatsapp_number { nil }
    end
  end
end
