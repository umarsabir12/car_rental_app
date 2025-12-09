require 'rails_helper'

RSpec.describe InvoiceItem, type: :model do
  describe 'associations' do
    it { should belong_to(:invoice) }
  end

  describe 'validations' do
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:amount) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      invoice_item = build(:invoice_item)
      expect(invoice_item).to be_valid
    end

    it 'creates invoice_item with valid attributes' do
      invoice = create(:invoice)
      invoice_item = create(:invoice_item, invoice: invoice, description: 'Test Item', amount: 100)

      expect(invoice_item.invoice).to eq(invoice)
      expect(invoice_item.description).to eq('Test Item')
      expect(invoice_item.amount).to eq(100)
    end
  end

  describe 'instance methods' do
    let(:invoice_item) { create(:invoice_item, amount: 250, description: 'Monthly rental') }

    it 'persists amount correctly' do
      expect(invoice_item.amount).to eq(250)
    end

    it 'persists description correctly' do
      expect(invoice_item.description).to eq('Monthly rental')
    end
  end

  describe 'invoice relationship' do
    it 'belongs to an invoice' do
      invoice = create(:invoice)
      invoice_item = create(:invoice_item, invoice: invoice)

      expect(invoice_item.invoice).to eq(invoice)
    end

    it 'is destroyed when invoice is destroyed' do
      invoice = create(:invoice, :with_items)
      invoice_item_ids = invoice.invoice_items.pluck(:id)

      invoice.destroy

      invoice_item_ids.each do |id|
        expect(InvoiceItem.find_by(id: id)).to be_nil
      end
    end
  end

  describe 'validations edge cases' do
    it 'is invalid without description' do
      invoice_item = build(:invoice_item, description: nil)
      expect(invoice_item).not_to be_valid
      expect(invoice_item.errors[:description]).to include("can't be blank")
    end

    it 'is invalid without amount' do
      invoice_item = build(:invoice_item, amount: nil)
      expect(invoice_item).not_to be_valid
      expect(invoice_item.errors[:amount]).to include("can't be blank")
    end

    it 'accepts zero amount' do
      invoice_item = build(:invoice_item, amount: 0)
      expect(invoice_item).to be_valid
    end

    it 'accepts negative amount' do
      invoice_item = build(:invoice_item, amount: -100)
      expect(invoice_item).to be_valid
    end

    it 'accepts decimal amounts' do
      invoice_item = build(:invoice_item, amount: 99.99)
      expect(invoice_item).to be_valid
      expect(invoice_item.amount).to eq(99.99)
    end
  end

  describe 'multiple items per invoice' do
    it 'allows multiple items for the same invoice' do
      invoice = create(:invoice)
      item1 = create(:invoice_item, invoice: invoice, description: 'Item 1', amount: 100)
      item2 = create(:invoice_item, invoice: invoice, description: 'Item 2', amount: 200)

      expect(invoice.invoice_items.count).to eq(2)
      expect(invoice.invoice_items).to include(item1, item2)
    end
  end
end
