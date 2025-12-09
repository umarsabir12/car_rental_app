FactoryBot.define do
  factory :invoice do
    association :vendor
    amount { rand(100..5000) }
    payment_mode { 'Online' }
    payment_status { 'pending' }

    trait :pending do
      payment_status { 'pending' }
      paid_at { nil }
    end

    trait :paid do
      payment_status { 'paid' }
      paid_at { Time.current }
    end

    trait :cancelled do
      payment_status { 'cancelled' }
    end

    trait :overdue do
      payment_status { 'overdue' }
      created_at { 31.days.ago }
    end

    trait :cash do
      payment_mode { 'Cash' }
    end

    trait :with_items do
      after(:create) do |invoice|
        create_list(:invoice_item, 3, invoice: invoice)
      end
    end
  end
end
