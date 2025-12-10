FactoryBot.define do
  factory :car_document do
    association :car
    document_status { :pending }

    after(:build) do |car_document|
      car_document.mulkiya.attach(
        io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'test_image.jpg')),
        filename: 'mulkiya.jpg',
        content_type: 'image/jpeg'
      ) unless car_document.mulkiya.attached?
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

    trait :pdf do
      after(:build) do |car_document|
        car_document.mulkiya.purge if car_document.mulkiya.attached?
        car_document.mulkiya.attach(
          io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'test_document.pdf')),
          filename: 'mulkiya.pdf',
          content_type: 'application/pdf'
        )
      end
    end
  end
end
