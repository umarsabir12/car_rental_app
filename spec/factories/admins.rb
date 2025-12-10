FactoryBot.define do
  factory :admin do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.unique.email }
    password { 'Password123!' }
    password_confirmation { 'Password123!' }
    role_type { 'admin' }

    trait :super_admin do
      role_type { 'super_admin' }
    end
  end
end
