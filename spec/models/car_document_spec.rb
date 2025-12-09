require 'rails_helper'

RSpec.describe CarDocument, type: :model do
  describe 'associations' do
    it { should belong_to(:car) }
  end

  describe 'validations' do
    it 'validates presence of mulkiya' do
      car_document = build(:car_document)
      car_document.mulkiya.purge
      expect(car_document).not_to be_valid
      expect(car_document.errors[:mulkiya]).to include('is required for all cars')
    end

    it 'validates mulkiya content type' do
      car_document = build(:car_document)
      expect(car_document).to be_valid
    end
  end

  describe 'enums' do
    it { should define_enum_for(:document_status).with_values(pending: 0, approved: 1, rejected: 2) }
  end

  describe 'traits' do
    it 'creates pending car document' do
      car_document = create(:car_document, :pending)
      expect(car_document.document_status).to eq('pending')
    end

    it 'creates approved car document' do
      car_document = create(:car_document, :approved)
      expect(car_document.document_status).to eq('approved')
    end

    it 'creates rejected car document' do
      car_document = create(:car_document, :rejected)
      expect(car_document.document_status).to eq('rejected')
    end
  end
end
