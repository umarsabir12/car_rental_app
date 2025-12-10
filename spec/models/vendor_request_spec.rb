require 'rails_helper'

RSpec.describe VendorRequest, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should validate_presence_of(:vehicle_count) }
    it { should validate_presence_of(:company_name) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(pending: 0, approved: 1, rejected: 2).with_default(:pending) }
  end

  describe 'scopes' do
    let!(:pending_request) { create(:vendor_request, :pending) }
    let!(:approved_request) { create(:vendor_request, :approved) }
    let!(:rejected_request) { create(:vendor_request, :rejected) }

    describe '.pending' do
      it 'returns only pending requests' do
        expect(VendorRequest.pending).to include(pending_request)
        expect(VendorRequest.pending).not_to include(approved_request)
      end
    end

    describe '.approved' do
      it 'returns only approved requests' do
        expect(VendorRequest.approved).to include(approved_request)
        expect(VendorRequest.approved).not_to include(pending_request)
      end
    end

    describe '.rejected' do
      it 'returns only rejected requests' do
        expect(VendorRequest.rejected).to include(rejected_request)
        expect(VendorRequest.rejected).not_to include(pending_request)
      end
    end
  end

  describe '#full_name' do
    it 'returns first and last name combined' do
      vendor_request = build(:vendor_request, first_name: 'John', last_name: 'Doe')
      expect(vendor_request.full_name).to eq('John Doe')
    end
  end

  describe '#approve!' do
    it 'sets status to approved' do
      vendor_request = create(:vendor_request, :pending)
      vendor_request.approve!
      expect(vendor_request.reload.status).to eq('approved')
    end
  end

  describe '#reject!' do
    it 'sets status to rejected' do
      vendor_request = create(:vendor_request, :pending)
      vendor_request.reject!
      expect(vendor_request.reload.status).to eq('rejected')
    end
  end
end
