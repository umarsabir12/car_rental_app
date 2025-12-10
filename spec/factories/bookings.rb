FactoryBot.define do
  factory :booking do
    association :car
    association :user
    association :vendor
    start_date { 1.day.from_now }
    end_date { 8.days.from_now }
    selected_period { 'weekly' }
    selected_price { car&.weekly_price || 300 }
    total_amount { 0 }
    status { 'pending' }
    payment_mode { 'Online' }
    payment_processed { false }

    trait :daily do
      selected_period { 'daily' }
      start_date { 1.day.from_now }
      end_date { 2.days.from_now }
      selected_price { car&.daily_price || 50 }
    end

    trait :weekly do
      selected_period { 'weekly' }
      start_date { 1.week.from_now }
      end_date { 2.weeks.from_now }
      selected_price { car&.weekly_price || 300 }
    end

    trait :monthly do
      selected_period { 'monthly' }
      start_date { 1.month.from_now }
      end_date { 2.months.from_now }
      selected_price { car&.monthly_price || 1200 }
    end

    trait :confirmed do
      status { 'confirmed' }
      payment_processed { true }
    end

    trait :cancelled do
      status { 'cancelled' }
    end

    trait :cash_payment do
      payment_mode { 'Cash' }
    end

    trait :past do
      start_date { 10.days.ago }
      end_date { 3.days.ago }
    end

    trait :current do
      start_date { 1.day.ago }
      end_date { 5.days.from_now }
    end

    trait :future do
      start_date { 10.days.from_now }
      end_date { 17.days.from_now }
    end
  end
end
