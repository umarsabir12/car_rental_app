require 'rails_helper'

RSpec.describe Transaction, type: :model do
  describe 'associations' do
    it { should belong_to(:booking) }
  end

  describe 'validations' do
    subject { build(:transaction) }

    it { should validate_presence_of(:amount) }
    it { should validate_numericality_of(:amount).is_greater_than(0) }
    it { should validate_presence_of(:status) }
    it { should validate_inclusion_of(:status).in_array(%w[pending completed failed refunded]) }
    it { should validate_presence_of(:transaction_type) }
    it { should validate_inclusion_of(:transaction_type).in_array(%w[payment refund]) }
  end

  describe 'scopes' do
    let!(:completed_transaction) { create(:transaction, :completed) }
    let!(:pending_transaction) { create(:transaction, :pending) }
    let!(:failed_transaction) { create(:transaction, :failed) }
    let!(:refunded_transaction) { create(:transaction, :refunded) }

    describe '.completed' do
      it 'returns only completed transactions' do
        expect(Transaction.completed).to include(completed_transaction)
        expect(Transaction.completed).not_to include(pending_transaction)
      end
    end

    describe '.pending' do
      it 'returns only pending transactions' do
        expect(Transaction.pending).to include(pending_transaction)
        expect(Transaction.pending).not_to include(completed_transaction)
      end
    end

    describe '.failed' do
      it 'returns only failed transactions' do
        expect(Transaction.failed).to include(failed_transaction)
      end
    end

    describe '.refunded' do
      it 'returns only refunded transactions' do
        expect(Transaction.refunded).to include(refunded_transaction)
      end
    end

    describe '.payments' do
      let!(:payment_transaction) { create(:transaction, :payment) }
      let!(:refund_transaction) { create(:transaction, :refund) }

      it 'returns only payment transactions' do
        expect(Transaction.payments).to include(payment_transaction)
        expect(Transaction.payments).not_to include(refund_transaction)
      end
    end

    describe '.refunds' do
      let!(:payment_transaction) { create(:transaction, :payment) }
      let!(:refund_transaction) { create(:transaction, :refund) }

      it 'returns only refund transactions' do
        expect(Transaction.refunds).to include(refund_transaction)
        expect(Transaction.refunds).not_to include(payment_transaction)
      end
    end

    describe '.recent' do
      it 'orders transactions by created_at descending' do
        # Create in reverse chronological order to ensure proper timestamps
        travel_to(2.days.ago) do
          @old_transaction = create(:transaction)
        end
        travel_to(1.hour.ago) do
          @new_transaction = create(:transaction)
        end

        # Get only the test transactions to avoid interference from let! blocks
        test_transactions = Transaction.where(id: [@old_transaction.id, @new_transaction.id]).recent
        expect(test_transactions.first).to eq(@new_transaction)
        expect(test_transactions.last).to eq(@old_transaction)
      end
    end
  end


  describe '#status_display' do
    it 'returns formatted status for completed' do
      transaction = build(:transaction, :completed)
      expect(transaction.status_display).to eq('Payment Completed')
    end

    it 'returns formatted status for pending' do
      transaction = build(:transaction, :pending)
      expect(transaction.status_display).to eq('Payment Pending')
    end

    it 'returns formatted status for failed' do
      transaction = build(:transaction, :failed)
      expect(transaction.status_display).to eq('Payment Failed')
    end

    it 'returns formatted status for refunded' do
      transaction = build(:transaction, :refunded)
      expect(transaction.status_display).to eq('Refunded')
    end
  end

  describe '#type_display' do
    it 'returns titleized transaction type' do
      transaction = build(:transaction, transaction_type: 'payment')
      expect(transaction.type_display).to eq('Payment')
    end
  end

  describe '#amount_display' do
    it 'returns positive amount for payments' do
      transaction = build(:transaction, transaction_type: 'payment', amount: 100)
      expect(transaction.amount_display).to eq('$100.0')
    end

    it 'returns negative amount for refunds' do
      transaction = build(:transaction, transaction_type: 'refund', amount: 100)
      expect(transaction.amount_display).to eq('-$100.0')
    end
  end
end
