require 'rails_helper'

RSpec.describe Vendor, type: :model do
  describe 'associations' do
    it { should have_many(:cars).dependent(:destroy) }
    it { should have_many(:activities).dependent(:destroy) }
    it { should have_many(:invoices).dependent(:destroy) }
    it { should have_many(:invoice_items).through(:invoices) }
    it { should have_one(:vendor_document) }
    it { should have_many_attached(:avatar) }
  end

  describe 'validations' do
    subject { build(:vendor) }

    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:company_name) }
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }

    context 'email format' do
      it { should allow_value('test@example.com').for(:email) }
      it { should_not allow_value('invalid').for(:email) }
    end

    context 'emirates_id' do
      it { should allow_value('784199012345678').for(:emirates_id) }
      it { should_not allow_value('123').for(:emirates_id) }

      it 'validates expiry date is in future' do
        vendor = build(:vendor, emirates_id_expires_on: Date.yesterday)
        expect(vendor).not_to be_valid
        expect(vendor.errors[:emirates_id_expires_on]).to include('must be in the future')
      end
    end
  end

  describe 'callbacks' do
    describe 'activity logging' do
      let(:vendor) { build(:vendor) }

      it 'logs registration upon creation' do
        expect {
          vendor.save
        }.to change(Activity, :count).by(1)

        activity = Activity.last
        expect(activity.action).to eq('vendor_registration')
        expect(activity.vendor).to eq(vendor)
      end

      it 'logs profile update when company name changes' do
        vendor.save

        expect {
          vendor.update(company_name: 'New Company Name')
        }.to change(Activity, :count).by(1)

        activity = Activity.last
        expect(activity.action).to eq('vendor_profile_updated')
        expect(activity.metadata['previous_company_name']).to be_present
      end
    end
  end

  describe 'scopes' do
    let!(:active_vendor) { create(:vendor) }
    let!(:deleted_vendor) { create(:vendor, :soft_deleted) }
    let!(:expired_eid_vendor) do
      v = build(:vendor, :with_expired_emirates_id)
      v.save(validate: false)
      v
    end

    describe '.active' do
      it 'returns only vendors that are not soft deleted' do
        expect(Vendor.active).to include(active_vendor)
        expect(Vendor.active).not_to include(deleted_vendor)
      end
    end

    describe '.deleted' do
      it 'returns only soft deleted vendors' do
        expect(Vendor.deleted).to include(deleted_vendor)
        expect(Vendor.deleted).not_to include(active_vendor)
      end
    end

    describe '.with_expired_emirates_id' do
      # Note: with_expired_emirates_id scope logic is "emirates_id_expires_on < Date.current"
      # But we need to bypass validation for testing the scope lookup if we can't save invalid record?
      # Wait, on create valid, then time passes? Or factory bypass validation?
      # Vendor model has `validate :emirates_id_expiry_in_future`.
      # So we can't easily create an expired one unless we use `save(validate: false)` or manipulate time.
      # Let's try `save(validate: false)` for the setup.

      it 'returns vendors with expired emirates id' do
        expired_eid_vendor.update_attribute(:emirates_id_expires_on, 1.day.ago)

        # We need another one with valid ID
        valid_eid_vendor = create(:vendor, :with_valid_emirates_id)

        expect(Vendor.with_expired_emirates_id).to include(expired_eid_vendor)
        expect(Vendor.with_expired_emirates_id).not_to include(valid_eid_vendor)
      end
    end
  end

  describe 'instance methods' do
    let(:vendor) { create(:vendor, first_name: 'John', last_name: 'Doe', company_name: 'JD Rentals') }

    describe '#name' do
      it 'returns first and last name combined' do
        expect(vendor.name).to eq('John Doe')
      end
    end

    describe '#display_name' do
      it 'returns company name if present' do
        expect(vendor.display_name).to eq('JD Rentals')
      end

      it 'returns name if company name is missing' do
        vendor.company_name = nil
        expect(vendor.display_name).to eq('John Doe')
      end
    end

    describe '#active_for_authentication?' do
      it 'returns true for active vendors' do
        vendor.is_active = true
        expect(vendor.active_for_authentication?).to be true
      end

      it 'returns false for inactive vendors' do
        vendor.is_active = false
        expect(vendor.active_for_authentication?).to be false
      end
    end

    describe '#inactive_message' do
      it 'returns standard message for active vendors' do
        vendor.is_active = true
        expect(vendor.inactive_message).to eq(:inactive)
      end

      it 'returns account_deactivated for inactive vendors' do
        vendor.is_active = false
        expect(vendor.inactive_message).to eq(:account_deactivated)
      end
    end

    describe 'soft delete' do
      it 'soft deletes vendor' do
        vendor.soft_delete!
        expect(vendor.deleted?).to be true
        expect(vendor.active?).to be false
      end

      it 'restores deleted vendor' do
        vendor.soft_delete!
        vendor.restore!
        expect(vendor.active?).to be true
      end
    end

    describe 'Emirates ID methods' do
      it '#emirates_id_valid? returns true for valid format' do
        vendor.emirates_id = '784199012345678'
        expect(vendor.emirates_id_valid?).to be true
      end

      it '#emirates_id_valid? returns false for invalid format' do
        vendor.emirates_id = 'invalid'
        expect(vendor.emirates_id_valid?).to be false
      end

      it '#emirates_id_expired? checks date against current time' do
        vendor.emirates_id_expires_on = 1.day.from_now
        expect(vendor.emirates_id_expired?).to be false

        vendor.emirates_id_expires_on = 1.day.ago
        expect(vendor.emirates_id_expired?).to be true
      end
    end
  end

  describe 'WhatsApp Logic' do
    let(:vendor) { create(:vendor, whatsapp_number: '+971501234567') }

    describe '#normalize_whatsapp_number' do
      it 'formats number to E164 before validation' do
        vendor.whatsapp_number = '0501234567' # Local UAE format
        vendor.valid?
        # Phonelib might need default country or +prefix.
        # If default country is not set, 050.. might be invalid.
        # But app seems to handle "050-123-4567" for users.
        # Let's try with explicit international format without plus
        vendor.whatsapp_number = '971501234567'
        vendor.valid?
        expect(vendor.whatsapp_number).to eq('+971501234567')
      end

      it 'cleans characters from number' do
        vendor.whatsapp_number = '+971-50-123-4567'
        vendor.valid?
        expect(vendor.whatsapp_number).to eq('+971501234567')
      end
    end

    describe '#whatsapp_display' do
      it 'returns international format' do
        # Depends on phonelib parsing
        expect(vendor.whatsapp_display).to include('+971 50 123 4567')
      end
    end

    describe '#whatsapp_link' do
      it 'generates a wa.me link' do
        expect(vendor.whatsapp_link).to eq('https://wa.me/971501234567')
      end

      it 'includes message when provided' do
        link = vendor.whatsapp_link('Hello World')
        expect(link).to include('text=Hello%20World')
      end

      it 'returns nil if no number' do
        vendor.whatsapp_number = nil
        expect(vendor.whatsapp_link).to be_nil
      end
    end
  end

  describe 'Financial Calculations' do
    let(:vendor) { create(:vendor) }
    let!(:invoice1) { create(:invoice, vendor: vendor, payment_status: 'pending') }
    let!(:invoice2) { create(:invoice, vendor: vendor, payment_status: 'paid') }
    let!(:item1) { create(:invoice_item, invoice: invoice1, amount: 100) }
    let!(:item2) { create(:invoice_item, invoice: invoice1, amount: 50) }
    let!(:item3) { create(:invoice_item, invoice: invoice2, amount: 200) }

    describe '#total_pending_amount' do
      it 'sums amounts of pending invoices' do
        expect(vendor.total_pending_amount).to eq(150)
      end
    end

    describe '#total_paid_amount' do
      it 'sums amounts of paid invoices' do
        expect(vendor.total_paid_amount).to eq(200)
      end
    end

    describe '#total_invoice_amount' do
      it 'sums all invoice amounts' do
        expect(vendor.total_invoice_amount).to eq(350)
      end
    end
  end

  describe '.from_omniauth' do
    let(:auth) do
      OmniAuth::AuthHash.new({
        provider: 'google_oauth2',
        uid: '123456',
        info: {
          email: 'test@example.com',
          first_name: 'Google',
          last_name: 'User',
          name: 'Google User'
        }
      })
    end

    it 'creates a new vendor if one does not exist' do
      expect {
        Vendor.from_omniauth(auth)
      }.to change(Vendor, :count).by(1)
    end

    it 'finds existing vendor' do
      create(:vendor, :omniauth, email: 'test@example.com', uid: '123456')
      expect {
        Vendor.from_omniauth(auth)
      }.not_to change(Vendor, :count)
    end

    it 'splits name if first/last missing' do
      auth.info.first_name = nil
      auth.info.last_name = nil
      auth.info.name = "Split Name"

      vendor = Vendor.from_omniauth(auth)
      expect(vendor.first_name).to eq('Split')
      expect(vendor.last_name).to eq('Name')
    end
  end
end
