require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:bookings).dependent(:destroy) }
    it { should have_many(:documents).dependent(:destroy) }
    it { should have_many(:activities).dependent(:destroy) }
  end

  describe 'validations' do
    subject { build(:user) }

    it { should validate_presence_of(:first_name) }
    it { should validate_length_of(:first_name).is_at_least(2).is_at_most(50) }
    it { should validate_presence_of(:last_name) }
    it { should validate_length_of(:last_name).is_at_least(2).is_at_most(50) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_presence_of(:phone) }
    it { should validate_presence_of(:nationality) }
    it { should validate_inclusion_of(:nationality).in_array(%w[resident tourist]).with_message("must be either 'resident' or 'tourist'") }
    it { should allow_value(true).for(:terms_accepted) }

    describe 'email format' do
      it { should allow_value('user@example.com').for(:email) }
      it { should_not allow_value('invalid_email').for(:email) }
    end

    describe 'phone format' do
      it { should allow_value('+971501234567').for(:phone) }
      it { should allow_value('050-123-4567').for(:phone) }
      it { should_not allow_value('abc').for(:phone) }
    end

    describe 'whatsapp_number validations' do
      it 'validates phone format using phonelib' do
        user = build(:user, whatsapp_number: '+971501234567')
        expect(user).to be_valid
      end

      it 'rejects invalid phone numbers' do
        user = build(:user, whatsapp_number: '123')
        expect(user).not_to be_valid
      end

      it 'validates uniqueness of whatsapp_number' do
        create(:user, whatsapp_number: '+971501234567')
        duplicate_user = build(:user, whatsapp_number: '+971501234567')
        expect(duplicate_user).not_to be_valid
      end

      it 'allows blank whatsapp_number' do
        user = build(:user, whatsapp_number: nil)
        expect(user).to be_valid
      end
    end
  end

  describe '#full_name' do
    it 'returns first and last name combined' do
      user = build(:user, first_name: 'John', last_name: 'Doe')
      expect(user.full_name).to eq('John Doe')
    end
  end

  describe '#display_name' do
    it 'returns full name when both first and last name are present' do
      user = build(:user, first_name: 'John', last_name: 'Doe')
      expect(user.display_name).to eq('John Doe')
    end

    it 'returns first name when last name is blank' do
      user = build(:user, first_name: 'John', last_name: nil)
      expect(user.display_name).to eq('John')
    end

    it 'returns email prefix when first name is blank' do
      user = build(:user, first_name: nil, last_name: nil, email: 'john@example.com')
      expect(user.display_name).to eq('john')
    end
  end

  describe '.from_omniauth' do
    let(:auth) do
      double('Auth',
             provider: 'google_oauth2',
             uid: '123456',
             info: double('Info',
                          email: 'user@example.com',
                          first_name: 'John',
                          last_name: 'Doe',
                          name: 'John Doe'))
    end

    context 'when user exists' do
      let!(:existing_user) { create(:user, :omniauth, provider: 'google_oauth2', uid: '123456') }

      it 'returns existing user' do
        user = User.from_omniauth(auth, 'resident', true, false)
        expect(user.id).to eq(existing_user.id)
      end

      it 'updates nationality if not set' do
        existing_user.update_column(:nationality, nil)
        user = User.from_omniauth(auth, 'resident', true, false)
        expect(user.reload.nationality).to eq('resident')
      end
    end

    context 'when user does not exist' do
      it 'creates new user if creation is allowed' do
        expect {
          User.from_omniauth(auth, 'resident', true, true)
        }.to change(User, :count).by(1)
      end

      it 'returns nil if creation is not allowed' do
        user = User.from_omniauth(auth, 'resident', true, false)
        expect(user).to be_nil
      end

      it 'sets user attributes from auth' do
        user = User.from_omniauth(auth, 'resident', true, true)
        expect(user.email).to eq('user@example.com')
        expect(user.first_name).to eq('John')
        expect(user.last_name).to eq('Doe')
        expect(user.nationality).to eq('resident')
        expect(user.terms_accepted).to be true
      end
    end
  end

  describe '#booking_alert' do
    let(:user) { create(:user, :resident, :with_documents) }

    it 'returns true when documents are missing' do
      user.documents.destroy_all
      expect(user.booking_alert).to be true
    end

    it 'returns true when any document is rejected' do
      user.documents.first.update(status: 'rejected')
      expect(user.booking_alert).to be true
    end

    it 'returns false when all required documents are approved' do
      user.documents.update_all(status: 'approved')
      expect(user.booking_alert).to be false
    end
  end

  describe '#has_required_pending_document?' do
    let(:user) { create(:user, :resident, :with_documents) }

    it 'returns true when required documents are pending' do
      user.documents.first.update(status: 'pending')
      expect(user.has_required_pending_document?).to be true
    end

    it 'returns false when no documents are pending' do
      user.documents.update_all(status: 'approved')
      expect(user.has_required_pending_document?).to be false
    end
  end

  describe '#document_completion_percentage' do
    let(:user) { create(:user, :resident, :with_documents) }

    it 'returns 0 when no documents are approved' do
      expect(user.document_completion_percentage).to eq(0)
    end

    it 'returns 100 when all documents are approved' do
      user.documents.update_all(status: 'approved')
      expect(user.document_completion_percentage).to eq(100)
    end

    it 'returns 50 when half documents are approved' do
      total = user.documents.count
      user.documents.limit(total / 2).update_all(status: 'approved')
      expect(user.document_completion_percentage).to eq(50)
    end
  end

  describe 'WhatsApp number helpers' do
    let(:user) { create(:user, whatsapp_number: '+971501234567') }

    describe '#whatsapp_display' do
      it 'returns international format' do
        expect(user.whatsapp_display).to include('+971')
      end
    end

    describe '#whatsapp_e164' do
      it 'returns E164 format' do
        expect(user.whatsapp_e164).to start_with('+971')
      end
    end

    describe '#whatsapp_mobile?' do
      it 'returns true for valid mobile numbers' do
        expect(user.whatsapp_mobile?).to be true
      end
    end

    describe '#whatsapp_link' do
      it 'generates WhatsApp link' do
        link = user.whatsapp_link
        expect(link).to include('wa.me')
      end

      it 'includes message in link when provided' do
        link = user.whatsapp_link('Hello')
        expect(link).to include('text=')
      end
    end
  end

  describe 'callbacks' do
    describe 'after_create' do
      it 'creates required documents' do
        user = build(:user, :resident)
        expect {
          user.save
        }.to change(Document, :count).by(Document::RESIDENT.count)
      end

      it 'logs registration activity' do
        expect {
          create(:user)
        }.to change(Activity, :count).by(1)

        activity = Activity.last
        expect(activity.action).to eq('registration_completed')
      end
    end

    describe 'before_validation' do
      it 'normalizes whatsapp_number to E164 format' do
        user = create(:user, whatsapp_number: '971501234567')
        expect(user.whatsapp_number).to eq('+971501234567')
      end
    end
  end

  describe 'document notification methods' do
    let(:user) { create(:user, :with_documents) }

    describe '#missing_documents' do
      it 'returns documents with not uploaded status' do
        expect(user.missing_documents.pluck(:status)).to all(eq('not uploaded'))
      end
    end

    describe '#approved_documents' do
      it 'returns documents with approved status' do
        user.documents.first.update(status: 'approved')
        expect(user.approved_documents.count).to eq(1)
      end
    end

    describe '#documents_notification?' do
      it 'returns true when there are missing or pending documents' do
        expect(user.documents_notification?).to be true
      end

      it 'returns false when all documents are approved' do
        user.documents.update_all(status: 'approved')
        expect(user.documents_notification?).to be false
      end
    end
  end

  describe '#has_notifications?' do
    let(:user) { create(:user, :with_documents) }

    it 'returns true when user has missing documents' do
      expect(user.has_notifications?).to be true
    end

    it 'returns true when user has unpaid bookings' do
      user.documents.update_all(status: 'approved')
      create(:booking, user: user, payment_processed: false)
      expect(user.has_notifications?).to be true
    end

    it 'returns false when everything is clear' do
      user.documents.update_all(status: 'approved')
      expect(user.has_notifications?).to be false
    end
  end
end
