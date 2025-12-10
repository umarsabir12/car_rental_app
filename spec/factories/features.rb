FactoryBot.define do
  factory :feature do
    name { Faker::Vehicle.unique.standard_specs }
    common { false }

    trait :common do
      common { true }
    end

    trait :premium do
      common { false }
    end
  end
end
