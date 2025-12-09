FactoryBot.define do
  factory :document do
    association :user
    doc_name { Document::RESIDENT.sample }
    document_type { 'Resident' }
    status { 'not uploaded' }

    trait :resident do
      doc_name { Document::RESIDENT.sample }
      document_type { 'Resident' }
    end

    trait :tourist do
      doc_name { Document::TOURIST.sample }
      document_type { 'Tourist' }
    end

    trait :pending do
      status { 'pending' }
      after(:build) do |document|
        document.images.attach(
          io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'test_image.jpg')),
          filename: 'test_document.jpg',
          content_type: 'image/jpeg'
        )
      end
    end

    trait :approved do
      status { 'approved' }
      after(:build) do |document|
        document.images.attach(
          io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'test_image.jpg')),
          filename: 'test_document.jpg',
          content_type: 'image/jpeg'
        )
      end
    end

    trait :rejected do
      status { 'rejected' }
      after(:build) do |document|
        document.images.attach(
          io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'test_image.jpg')),
          filename: 'test_document.jpg',
          content_type: 'image/jpeg'
        )
      end
    end
  end
end
