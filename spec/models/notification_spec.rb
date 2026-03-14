require 'rails_helper'

RSpec.describe Notification, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:message) }
    it { should validate_presence_of(:related_path) }
  end

  describe 'associations' do
    it { should belong_to(:admin) }
  end

  describe 'scopes' do
    let(:admin) { create(:admin) }
    let!(:unread_notification) { create(:notification, admin: admin, read_at: nil) }
    let!(:read_notification) { create(:notification, admin: admin, read_at: Time.current) }

    describe '.unread' do
      it 'returns only unread notifications' do
        expect(Notification.unread).to include(unread_notification)
        expect(Notification.unread).not_to include(read_notification)
      end
    end

    describe '.read' do
      it 'returns only read notifications' do
        expect(Notification.read).to include(read_notification)
        expect(Notification.read).not_to include(unread_notification)
      end
    end

    describe '.ordered' do
      let(:order_admin) { create(:admin) }
      it 'returns notifications unread first, then by creation date' do
        old_unread = create(:notification, admin: order_admin, read_at: nil, created_at: 1.day.ago)
        new_unread = create(:notification, admin: order_admin, read_at: nil, created_at: Time.current)
        read_notif = create(:notification, admin: order_admin, read_at: Time.current, created_at: 2.days.ago)

        ordered = order_admin.notifications.ordered
        expect(ordered.first).to eq(new_unread)
        expect(ordered[1]).to eq(old_unread)
        expect(ordered.last).to eq(read_notif)
      end
    end
  end

  describe 'instance methods' do
    let(:notification) { create(:notification, read_at: nil) }

    describe '#read?' do
      it 'returns false if read_at is nil' do
        expect(notification.read?).to be false
      end

      it 'returns true if read_at is present' do
        notification.update(read_at: Time.current)
        expect(notification.read?).to be true
      end
    end

    describe '#mark_as_read!' do
      it 'updates read_at' do
        expect {
          notification.mark_as_read!
        }.to change { notification.read_at }.from(nil)
      end
    end
  end

  describe 'broadcasts' do
    let(:admin) { create(:admin) }
    let(:notification) { build(:notification, admin: admin) }

    it 'triggers broadcasts after creation' do
      expect(notification).to receive(:broadcast_notification)
      notification.save!
    end

    it 'triggers broadcast_notification_status after updating read_at' do
      notification.save!
      expect(notification).to receive(:broadcast_notification_status)
      notification.mark_as_read!
    end
  end
end
