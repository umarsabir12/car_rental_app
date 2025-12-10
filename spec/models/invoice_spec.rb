require 'rails_helper'

RSpec.describe Invoice, type: :model do
  describe 'associations' do
    it { should belong_to(:vendor) }
    it { should have_many(:invoice_items).dependent(:destroy) }
    it { should accept_nested_attributes_for(:invoice_items).allow_destroy(true) }
  end

  describe 'validations' do
    subject { build(:invoice) }

    it { should validate_presence_of(:amount) }
    it { should validate_numericality_of(:amount).is_greater_than(0) }
    it { should validate_inclusion_of(:payment_mode).in_array(Invoice::PAYMENT_MODES) }
    it { should validate_inclusion_of(:payment_status).in_array(Invoice::PAYMENT_STATUSES) }
  end

  describe 'constants' do
    it 'defines PAYMENT_STATUSES' do
      expect(Invoice::PAYMENT_STATUSES).to eq(%w[pending paid cancelled overdue])
    end

    it 'defines PAYMENT_MODES' do
      expect(Invoice::PAYMENT_MODES).to eq(%w[Online Cash])
    end
  end

  describe 'scopes' do
    let!(:pending_invoice) { create(:invoice, :pending) }
    let!(:paid_invoice) { create(:invoice, :paid) }
    let!(:cancelled_invoice) { create(:invoice, :cancelled) }
    let!(:overdue_invoice) { create(:invoice, :overdue) }

    describe '.pending' do
      it 'returns pending invoices' do
        expect(Invoice.pending).to include(pending_invoice)
        expect(Invoice.pending).not_to include(paid_invoice)
      end
    end

    describe '.paid' do
      it 'returns paid invoices' do
        expect(Invoice.paid).to include(paid_invoice)
        expect(Invoice.paid).not_to include(pending_invoice)
      end
    end

    describe '.overdue' do
      it 'returns overdue invoices' do
        expect(Invoice.overdue).to include(overdue_invoice)
        expect(Invoice.overdue).not_to include(pending_invoice)
      end
    end

    describe '.recent' do
      it 'returns invoices in descending order by created_at' do
        # Create invoices with distinct timestamps using travel_to
        travel_to(2.days.ago) do
          @old_invoice = create(:invoice)
        end
        travel_to(1.hour.ago) do
          @new_invoice = create(:invoice)
        end

        # Get only the test invoices to avoid interference from let! blocks
        test_invoices = Invoice.where(id: [ @old_invoice.id, @new_invoice.id ]).recent
        expect(test_invoices.first).to eq(@new_invoice)
        expect(test_invoices.last).to eq(@old_invoice)
      end
    end
  end

  describe 'callbacks' do
    describe 'after_initialize' do
      it 'sets default payment_mode for new records' do
        invoice = Invoice.new
        expect(invoice.payment_mode).to eq('Online')
      end

      it 'does not override existing payment_mode' do
        invoice = Invoice.new(payment_mode: 'Cash')
        expect(invoice.payment_mode).to eq('Cash')
      end

      it 'does not set payment_mode for existing records' do
        invoice = create(:invoice, :cash)
        invoice.reload
        expect(invoice.payment_mode).to eq('Cash')
      end
    end
  end

  describe 'instance methods' do
    describe '#mark_as_paid!' do
      let(:invoice) { create(:invoice, :pending) }

      it 'updates payment_status to paid' do
        invoice.mark_as_paid!
        expect(invoice.reload.payment_status).to eq('paid')
      end

      it 'sets paid_at timestamp' do
        invoice.mark_as_paid!
        expect(invoice.reload.paid_at).to be_present
      end
    end

    describe '#calculate_total' do
      let(:invoice) { create(:invoice) }

      it 'calculates sum of invoice_items amounts' do
        create(:invoice_item, invoice: invoice, amount: 100)
        create(:invoice_item, invoice: invoice, amount: 200)
        create(:invoice_item, invoice: invoice, amount: 150)

        expect(invoice.calculate_total).to eq(450)
      end

      it 'returns 0 when no invoice_items exist' do
        expect(invoice.calculate_total).to eq(0)
      end
    end

    describe '#formatted_amount' do
      it 'returns formatted amount with AED currency' do
        invoice = build(:invoice, amount: 1500.50)
        expect(invoice.formatted_amount).to eq('AED 1500')
      end

      it 'handles integer amounts' do
        invoice = build(:invoice, amount: 1000)
        expect(invoice.formatted_amount).to eq('AED 1000')
      end
    end

    describe '#can_process_payment?' do
      it 'returns true for pending status' do
        invoice = build(:invoice, :pending)
        expect(invoice.can_process_payment?).to be true
      end

      it 'returns true for overdue status' do
        invoice = build(:invoice, :overdue)
        expect(invoice.can_process_payment?).to be true
      end

      it 'returns false for paid status' do
        invoice = build(:invoice, :paid)
        expect(invoice.can_process_payment?).to be false
      end

      it 'returns false for cancelled status' do
        invoice = build(:invoice, :cancelled)
        expect(invoice.can_process_payment?).to be false
      end
    end
  end

  describe 'nested attributes' do
    it 'accepts nested attributes for invoice_items' do
      vendor = create(:vendor)
      invoice_params = {
        vendor: vendor,
        amount: 500,
        payment_mode: 'Online',
        payment_status: 'pending',
        invoice_items_attributes: [
          { description: 'Item 1', amount: 100 },
          { description: 'Item 2', amount: 200 }
        ]
      }

      invoice = Invoice.create!(invoice_params)

      expect(invoice.invoice_items.count).to eq(2)
      expect(invoice.invoice_items.pluck(:description)).to include('Item 1', 'Item 2')
    end

    it 'allows destroying invoice_items' do
      invoice = create(:invoice, :with_items)
      item_to_destroy = invoice.invoice_items.first

      invoice.update(
        invoice_items_attributes: [
          { id: item_to_destroy.id, _destroy: '1' }
        ]
      )

      expect(invoice.invoice_items).not_to include(item_to_destroy)
    end
  end
end
