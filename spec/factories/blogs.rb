FactoryBot.define do
  factory :blog do
    title { Faker::Lorem.sentence }
    content { Faker::Lorem.paragraphs(number: 3).join("\n\n") }
    category { %w[Tips News Guides Reviews].sample }
    author_name { Faker::Name.name }
    published_at { Time.current }

    after(:build) do |blog|
      blog.featured_image.attach(
        io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'test_image.jpg')),
        filename: 'featured_image.jpg',
        content_type: 'image/jpeg'
      ) unless blog.featured_image.attached?
    end

    trait :draft do
      published_at { nil }
    end

    trait :published do
      published_at { 1.day.ago }
    end

    trait :scheduled do
      published_at { 1.week.from_now }
    end
  end
end
