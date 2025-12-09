require 'rails_helper'

RSpec.describe Activity, type: :model do
  describe 'associations' do
    it { should belong_to(:user).optional }
    it { should belong_to(:vendor).optional }
    it { should belong_to(:subject) }
  end

  describe 'validations' do
    subject { build(:activity, :for_user) }

    it { should validate_presence_of(:action) }
    it { should validate_presence_of(:description) }
    it { should validate_inclusion_of(:action).in_array(Activity::ACTIONS) }

    describe 'user_or_vendor_present validation' do
      it 'is valid when user is present' do
        activity = build(:activity, :for_user)
        expect(activity).to be_valid
      end

      it 'is valid when vendor is present' do
        activity = build(:activity, :for_vendor)
        expect(activity).to be_valid
      end

      it 'is invalid when both user and vendor are nil' do
        activity = build(:activity, user: nil, vendor: nil)
        expect(activity).not_to be_valid
        expect(activity.errors[:base]).to include('Either user or vendor must be present')
      end

      it 'is valid when both user and vendor are present' do
        activity = build(:activity, user: create(:user), vendor: create(:vendor))
        expect(activity).to be_valid
      end
    end

    describe 'action validation' do
      it 'allows valid actions' do
        Activity::ACTIONS.each do |action|
          activity = build(:activity, :for_user, action: action)
          expect(activity).to be_valid
        end
      end

      it 'rejects invalid actions' do
        activity = build(:activity, :for_user, action: 'invalid_action')
        expect(activity).not_to be_valid
      end
    end
  end

  describe 'scopes' do
    let!(:booking_activity) { create(:activity, :booking_created, user: create(:user)) }
    let!(:document_activity) { create(:activity, :document_uploaded, user: create(:user)) }
    let(:user) { create(:user) }
    let(:vendor) { create(:vendor) }
    let!(:user_activity) { create(:activity, user: user, vendor: nil, subject: user, action: 'profile_updated', description: 'Test') }
    let!(:vendor_activity) { create(:activity, vendor: vendor, user: nil, subject: vendor, action: 'vendor_registration', description: 'Test') }

    describe '.recent' do
      it 'returns activities in descending order by created_at' do
        # Create activities with distinct timestamps using travel_to
        travel_to(2.days.ago) do
          @old_activity = create(:activity, :for_user)
        end
        travel_to(1.hour.ago) do
          @new_activity = create(:activity, :for_user)
        end

        # Get only the test activities to avoid interference from let! blocks
        test_activities = Activity.where(id: [@old_activity.id, @new_activity.id]).recent
        expect(test_activities.first).to eq(@new_activity)
        expect(test_activities.last).to eq(@old_activity)
      end
    end

    describe '.by_action' do
      it 'returns activities with specified action' do
        expect(Activity.by_action('booking_created')).to include(booking_activity)
        expect(Activity.by_action('booking_created')).not_to include(document_activity)
      end
    end

    describe '.by_user' do
      it 'returns activities for specified user' do
        expect(Activity.by_user(user)).to include(user_activity)
        expect(Activity.by_user(user)).not_to include(vendor_activity)
      end
    end

    describe '.by_vendor' do
      it 'returns activities for specified vendor' do
        expect(Activity.by_vendor(vendor)).to include(vendor_activity)
        expect(Activity.by_vendor(vendor)).not_to include(user_activity)
      end
    end

    describe '.user_activities' do
      it 'returns activities with user_id present' do
        expect(Activity.user_activities).to include(user_activity)
        expect(Activity.user_activities).not_to include(vendor_activity)
      end
    end

    describe '.vendor_activities' do
      it 'returns activities with vendor_id present' do
        expect(Activity.vendor_activities).to include(vendor_activity)
        expect(Activity.vendor_activities).not_to include(user_activity)
      end
    end
  end

  describe 'class methods' do
    describe '.log_activity' do
      it 'creates an activity with user' do
        user = create(:user)
        subject_record = create(:booking, user: user)

        expect {
          Activity.log_activity(
            user: user,
            subject: subject_record,
            action: 'booking_created',
            description: 'New booking created'
          )
        }.to change(Activity, :count).by(1)

        activity = Activity.last
        expect(activity.user).to eq(user)
        expect(activity.subject).to eq(subject_record)
        expect(activity.action).to eq('booking_created')
      end

      it 'creates an activity with vendor' do
        vendor = create(:vendor)
        car = create(:car, vendor: vendor)

        expect {
          Activity.log_activity(
            vendor: vendor,
            subject: car,
            action: 'car_added',
            description: 'New car added'
          )
        }.to change(Activity, :count).by(1)

        activity = Activity.last
        expect(activity.vendor).to eq(vendor)
      end

      it 'stores metadata as JSON' do
        user = create(:user)
        subject_record = create(:booking, user: user)
        metadata = { booking_id: 123, amount: 500 }

        Activity.log_activity(
          user: user,
          subject: subject_record,
          action: 'booking_created',
          description: 'Test',
          metadata: metadata
        )

        activity = Activity.last
        expect(activity.metadata).to be_present
        expect(activity.metadata_hash).to eq(metadata.stringify_keys)
      end

      it 'stores request information when provided' do
        user = create(:user)
        subject_record = create(:booking, user: user)
        request = double('Request', remote_ip: '127.0.0.1', user_agent: 'Test Browser')

        Activity.log_activity(
          user: user,
          subject: subject_record,
          action: 'booking_created',
          description: 'Test',
          request: request
        )

        activity = Activity.last
        expect(activity.ip_address).to eq('127.0.0.1')
        expect(activity.user_agent).to eq('Test Browser')
      end
    end
  end

  describe 'instance methods' do
    describe '#metadata_hash' do
      it 'returns parsed JSON metadata' do
        activity = create(:activity, :for_user, metadata: { key: 'value' }.to_json)
        expect(activity.metadata_hash).to eq({ 'key' => 'value' })
      end

      it 'returns empty hash when metadata is blank' do
        activity = create(:activity, :for_user, metadata: nil)
        expect(activity.metadata_hash).to eq({})
      end

      it 'returns empty hash when metadata is invalid JSON' do
        activity = create(:activity, :for_user, metadata: 'invalid json')
        expect(activity.metadata_hash).to eq({})
      end
    end

    describe '#formatted_time' do
      it 'returns formatted timestamp' do
        activity = create(:activity, :for_user, created_at: Time.zone.parse('2023-01-15 14:30:00'))
        expect(activity.formatted_time).to match(/Jan 15, 2023 at \d{2}:\d{2} (AM|PM)/)
      end
    end

    describe '#action_icon' do
      it 'returns correct icon for booking actions' do
        activity = build(:activity, :for_user, action: 'booking_created')
        expect(activity.action_icon).to eq('fas fa-calendar-check')
      end

      it 'returns correct icon for document actions' do
        activity = build(:activity, :for_user, action: 'document_uploaded')
        expect(activity.action_icon).to eq('fas fa-file-upload')
      end

      it 'returns correct icon for car actions' do
        activity = build(:activity, :for_user, action: 'car_added')
        expect(activity.action_icon).to eq('fas fa-car')
      end

      it 'returns correct icon for registration actions' do
        activity = build(:activity, :for_user, action: 'vendor_registration')
        expect(activity.action_icon).to eq('fas fa-user-plus')
      end

      it 'returns default icon for unknown actions' do
        activity = build(:activity, :for_user, action: 'profile_updated')
        expect(activity.action_icon).to eq('fas fa-circle')
      end
    end

    describe '#action_color' do
      it 'returns blue for creation actions' do
        activity = build(:activity, :for_user, action: 'booking_created')
        expect(activity.action_color).to eq('text-blue-600')
      end

      it 'returns green for approval actions' do
        activity = build(:activity, :for_user, action: 'booking_confirmed')
        expect(activity.action_color).to eq('text-green-600')
      end

      it 'returns red for rejection/cancellation actions' do
        activity = build(:activity, :for_user, action: 'booking_cancelled')
        expect(activity.action_color).to eq('text-red-600')
      end

      it 'returns purple for update actions' do
        activity = build(:activity, :for_user, action: 'profile_updated')
        expect(activity.action_color).to eq('text-purple-600')
      end

      it 'returns gray for unknown actions' do
        activity = build(:activity, :for_user, action: 'vendor_activated')
        expect(activity.action_color).to eq('text-gray-600')
      end
    end

    describe '#actor_name' do
      it 'returns user full_name when user is present' do
        user = create(:user, first_name: 'John', last_name: 'Doe')
        activity = build(:activity, user: user, vendor: nil, subject: user, action: 'profile_updated', description: 'Test')
        expect(activity.actor_name).to eq('John Doe')
      end

      it 'returns vendor company_name when vendor is present' do
        vendor = create(:vendor, company_name: 'Acme Corp')
        activity = build(:activity, vendor: vendor, user: nil, subject: vendor, action: 'vendor_registration', description: 'Test')
        expect(activity.actor_name).to eq('Acme Corp')
      end

      it 'returns System when both user and vendor are nil' do
        activity = build(:activity, user: nil, vendor: nil)
        expect(activity.actor_name).to eq('System')
      end
    end

    describe '#actor_type' do
      it 'returns User when user is present' do
        user = create(:user)
        activity = build(:activity, user: user, vendor: nil, subject: user, action: 'profile_updated', description: 'Test')
        expect(activity.actor_type).to eq('User')
      end

      it 'returns Vendor when vendor is present' do
        vendor = create(:vendor)
        activity = build(:activity, vendor: vendor, user: nil, subject: vendor, action: 'vendor_registration', description: 'Test')
        expect(activity.actor_type).to eq('Vendor')
      end

      it 'returns System when both user and vendor are nil' do
        activity = build(:activity, user: nil, vendor: nil)
        expect(activity.actor_type).to eq('System')
      end
    end
  end

  describe 'ACTIONS constant' do
    it 'includes all expected action types' do
      expected_actions = %w[
        booking_created booking_confirmed booking_cancelled
        document_uploaded document_pending document_approved document_rejected
        payment_received payment_failed
        profile_updated car_viewed registration_completed
        vendor_registration vendor_activated vendor_deactivated
        car_added car_updated car_deleted
        vendor_deleted vendor_restored
        car_document_approved car_document_rejected
        vendor_document_approved vendor_document_rejected
      ]

      expected_actions.each do |action|
        expect(Activity::ACTIONS).to include(action)
      end
    end
  end
end
