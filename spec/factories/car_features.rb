FactoryBot.define do
  factory :car_feature do
    association :car
    association :feature
  end
end
