FactoryBot.define do
  factory :vendor_document do
    association :vendor
    document_status { :pending }

    after(:build) do |vendor_document|
      vendor_document.trade_license.attach(
        io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'test_image.jpg')),
        filename: 'trade_license.jpg',
        content_type: 'image/jpeg'
      ) unless vendor_document.trade_license.attached?
    end

    trait :pending do
      document_status { :pending }
    end

    trait :approved do
      document_status { :approved }
    end

    trait :rejected do
      document_status { :rejected }
    end
  end
end
