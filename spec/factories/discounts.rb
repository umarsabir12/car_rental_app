FactoryBot.define do
  factory :discount do
    association :vendor
    category { [] }
    discount_percentage { 15.0 }
    active { true }

    trait :vendor_specific_category do
      category { ['Luxury'] }
    end

    trait :category_only do
      vendor { nil }
      category { ['Economy'] }
    end

    trait :all_categories do
      category { [] }
    end

    trait :inactive do
      active { false }
    end

    trait :high_discount do
      discount_percentage { 30.0 }
    end

    trait :low_discount do
      discount_percentage { 5.0 }
    end
  end
end
