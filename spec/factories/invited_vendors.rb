FactoryBot.define do
  factory :invited_vendor do
    email { Faker::Internet.unique.email }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    invite_token { SecureRandom.hex(10) }
    status { 'pending' }
    invite_sent { false }
  end
end
