FactoryBot.define do
  factory :vendor do
    email { Faker::Internet.unique.email }
    sequence(:company_name) { |n| "#{Faker::Company.name} #{n}" }
    sequence(:first_name) { |n| "#{Faker::Name.first_name}#{n}" }
    sequence(:last_name) { |n| "#{Faker::Name.last_name}#{n}" }
    password { 'Password123!' }
    password_confirmation { 'Password123!' }
    phone { '+971501234567' }
    sequence(:whatsapp_number) { |n| "+97152#{sprintf('%07d', n)}" }
    is_active { true }

    trait :inactive do
      is_active { false }
    end

    trait :with_cars do
      after(:create) do |vendor|
        create_list(:car, 3, vendor: vendor)
      end
    end

    trait :with_invoices do
      after(:create) do |vendor|
        create_list(:invoice, 2, vendor: vendor)
      end
    end

    trait :with_valid_emirates_id do
      emirates_id { Faker::Number.number(digits: 15).to_s }
      emirates_id_expires_on { 1.year.from_now }
    end

    trait :with_expired_emirates_id do
      emirates_id { Faker::Number.number(digits: 15).to_s }
      emirates_id_expires_on { 1.day.ago }
    end

    trait :soft_deleted do
      deleted_at { Time.current }
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
