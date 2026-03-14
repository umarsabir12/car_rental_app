FactoryBot.define do
  factory :notification do
    association :admin
    title { "New Notification" }
    message { "A new event has occurred." }
    related_path { "/admin" }
    read_at { nil }
  end
end
