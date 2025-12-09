FactoryBot.define do
  factory :transaction do
    association :booking
    amount { rand(100..1000) }
    status { 'pending' }
    transaction_type { 'payment' }

    trait :pending do
      status { 'pending' }
      processed_at { nil }
    end

    trait :completed do
      status { 'completed' }
      processed_at { Time.current }
    end

    trait :failed do
      status { 'failed' }
      processed_at { Time.current }
    end

    trait :refunded do
      status { 'refunded' }
      refund_amount { amount }
      refund_reason { 'Customer request' }
    end

    trait :payment do
      transaction_type { 'payment' }
    end

    trait :refund do
      transaction_type { 'refund' }
    end
  end
end
