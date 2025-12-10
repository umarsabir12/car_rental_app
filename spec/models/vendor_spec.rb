require 'rails_helper'

RSpec.describe Vendor, type: :model do
  describe 'associations' do
    it { should have_many(:cars).dependent(:destroy) }
    it { should have_many(:activities).dependent(:destroy) }
    it { should have_many(:invoices).dependent(:destroy) }
    it { should have_many(:invoice_items).through(:invoices) }
    it { should have_one(:vendor_document) }
  end

  describe 'validations' do
    subject { build(:vendor) }

    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:company_name) }
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
  end

  describe '#name' do
    it 'returns first and last name combined' do
      vendor = build(:vendor, first_name: 'John', last_name: 'Doe')
      expect(vendor.name).to eq('John Doe')
    end
  end

  describe 'soft delete methods' do
    let(:vendor) { create(:vendor) }

    it 'soft deletes vendor' do
      vendor.soft_delete!
      expect(vendor.deleted?).to be true
    end

    it 'restores deleted vendor' do
      vendor.soft_delete!
      vendor.restore!
      expect(vendor.active?).to be true
    end
  end
end
