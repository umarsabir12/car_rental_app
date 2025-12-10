FactoryBot.define do
  factory :vendor_request do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.unique.email }
    company_name { Faker::Company.name }
    vehicle_count { rand(1..50) }
    status { :pending }

    trait :pending do
      status { :pending }
    end

    trait :approved do
      status { :approved }
    end

    trait :rejected do
      status { :rejected }
    end
  end
end
