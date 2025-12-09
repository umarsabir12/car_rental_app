require 'rails_helper'

RSpec.describe VendorDocument, type: :model do
  describe 'associations' do
    it { should belong_to(:vendor) }
  end

  describe 'validations' do
    it 'validates presence of trade_license' do
      vendor_document = build(:vendor_document)
      vendor_document.trade_license.purge
      expect(vendor_document).not_to be_valid
      expect(vendor_document.errors[:trade_license]).to include('is required for vendor')
    end
  end

  describe 'enums' do
    it { should define_enum_for(:document_status).with_values(pending: 0, approved: 1, rejected: 2) }
  end

  describe 'traits' do
    it 'creates pending vendor document' do
      vendor_document = create(:vendor_document, :pending)
      expect(vendor_document.document_status).to eq('pending')
    end

    it 'creates approved vendor document' do
      vendor_document = create(:vendor_document, :approved)
      expect(vendor_document.document_status).to eq('approved')
    end

    it 'creates rejected vendor document' do
      vendor_document = create(:vendor_document, :rejected)
      expect(vendor_document.document_status).to eq('rejected')
    end
  end
end
