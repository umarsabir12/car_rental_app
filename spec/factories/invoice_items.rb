FactoryBot.define do
  factory :invoice_item do
    association :invoice
    description { Faker::Commerce.product_name }
    amount { rand(50..1000) }
  end
end
