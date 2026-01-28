require 'rails_helper'

RSpec.describe Booking, type: :model do
  describe 'associations' do
    it { should belong_to(:car).counter_cache(true) }
    it { should belong_to(:user) }
    it { should belong_to(:vendor).optional }
    it { should have_many(:activities).dependent(:destroy) }
  end

  describe 'constants' do
    it 'defines STATUSES' do
      expect(Booking::STATUSES).to eq(%w[pending confirmed cancelled])
    end

    it 'defines PAYMENT_STATUSES' do
      expect(Booking::PAYMENT_STATUSES).to eq(%w[pending paid unpaid refunded refund_pending])
    end
  end

  describe 'validations' do
    it { should validate_presence_of(:car_id) }
    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:start_date) }
    it { should validate_presence_of(:end_date) }
    it { should validate_presence_of(:selected_period) }

    it 'validates status inclusion in STATUSES' do
      booking = build(:booking, status: 'invalid_status')
      expect(booking).not_to be_valid
      expect(booking.errors[:status]).to include('is not included in the list')
    end

    it 'validates payment_status inclusion in PAYMENT_STATUSES' do
      booking = build(:booking, payment_status: 'invalid_status')
      expect(booking).not_to be_valid
      expect(booking.errors[:payment_status]).to include('is not included in the list')
    end

    describe 'end_date_after_start_date' do
      let(:car) { create(:car) }
      let(:user) { create(:user, :with_approved_documents) }

      it 'is invalid when end_date is before start_date' do
        booking = build(:booking, car: car, user: user, start_date: Date.today, end_date: Date.yesterday)
        expect(booking).not_to be_valid
        expect(booking.errors[:end_date]).to include('must be after start date')
      end

      it 'is valid when end_date is after start_date' do
        booking = build(:booking, car: car, user: user, start_date: Date.today, end_date: Date.tomorrow)
        expect(booking).to be_valid
      end
    end

    describe 'no_overlapping_bookings' do
      let(:car) { create(:car) }
      let(:user) { create(:user, :with_approved_documents) }
      let!(:existing_booking) do
        create(:booking, :confirmed,
               car: car,
               user: user,
               start_date: Date.today + 5.days,
               end_date: Date.today + 10.days)
      end

      it 'prevents overlapping bookings for the same car' do
        overlapping_booking = build(:booking,
                                     car: car,
                                     user: user,
                                     start_date: Date.today + 7.days,
                                     end_date: Date.today + 12.days,
                                     payment_processed: true)
        expect(overlapping_booking).not_to be_valid
        expect(overlapping_booking.errors[:base]).to include('This car is already booked for the selected dates')
      end

      it 'allows non-overlapping bookings' do
        non_overlapping_booking = build(:booking,
                                         car: car,
                                         user: user,
                                         start_date: Date.today + 15.days,
                                         end_date: Date.today + 20.days)
        expect(non_overlapping_booking).to be_valid
      end

      it 'allows overlapping bookings if existing booking is not payment_processed' do
        existing_booking.update_column(:payment_processed, false)
        overlapping_booking = build(:booking,
                                     car: car,
                                     user: user,
                                     start_date: Date.today + 7.days,
                                     end_date: Date.today + 12.days)
        expect(overlapping_booking).to be_valid
      end
    end
  end

  describe 'enums' do
    it { should define_enum_for(:payment_mode).with_values(Cash: 0, Online: 1).with_default(:Online) }
  end

  describe 'scopes' do
    describe '.active' do
      let!(:active_booking) { create(:booking, start_date: Date.tomorrow) }
      let!(:past_booking) { create(:booking, :past) }

      it 'returns only future bookings' do
        expect(Booking.active).to include(active_booking)
        expect(Booking.active).not_to include(past_booking)
      end
    end

    describe '.paid' do
      let!(:paid_booking) { create(:booking, :paid) }
      let!(:unpaid_booking) { create(:booking, :unpaid) }

      it 'returns only paid bookings' do
        expect(Booking.paid).to include(paid_booking)
        expect(Booking.paid).not_to include(unpaid_booking)
      end
    end

    describe '.unpaid' do
      let!(:paid_booking) { create(:booking, :paid) }
      let!(:pending_booking) { create(:booking, payment_status: 'pending') }
      let!(:unpaid_booking) { create(:booking, :unpaid) }

      it 'returns pending and unpaid bookings' do
        expect(Booking.unpaid).to include(pending_booking, unpaid_booking)
        expect(Booking.unpaid).not_to include(paid_booking)
      end
    end
  end

  describe 'instance methods' do
    describe '#cancelled?' do
      it 'returns true when booking status is cancelled' do
        booking = build(:booking, :cancelled)
        expect(booking.cancelled?).to be true
      end

      it 'returns false when booking status is not cancelled' do
        booking = build(:booking, status: 'confirmed')
        expect(booking.cancelled?).to be false
      end
    end

    describe '#needs_refund?' do
      it 'returns true when payment_status is refunded' do
        booking = build(:booking, :refunded)
        expect(booking.needs_refund?).to be true
      end

      it 'returns true when payment_status is refund_pending' do
        booking = build(:booking, :refund_pending)
        expect(booking.needs_refund?).to be true
      end

      it 'returns false for other payment statuses' do
        booking = build(:booking, payment_status: 'paid')
        expect(booking.needs_refund?).to be false
      end
    end

    describe '#cancelled_with_refund?' do
      it 'returns true when booking is cancelled and needs refund' do
        booking = build(:booking, :refunded)
        expect(booking.cancelled_with_refund?).to be true
      end

      it 'returns false when booking is not cancelled' do
        booking = build(:booking, status: 'confirmed', payment_status: 'refunded')
        expect(booking.cancelled_with_refund?).to be false
      end

      it 'returns false when booking is cancelled but does not need refund' do
        booking = build(:booking, status: 'cancelled', payment_status: 'pending')
        expect(booking.cancelled_with_refund?).to be false
      end
    end

    describe '#payment_completed?' do
      it 'returns true when payment_status is paid' do
        booking = build(:booking, :paid)
        expect(booking.payment_completed?).to be true
      end

      it 'returns false when payment_status is not paid' do
        booking = build(:booking, payment_status: 'pending')
        expect(booking.payment_completed?).to be false
      end
    end

    describe '#cancel_by_admin!' do
      let(:booking) { create(:booking, status: 'confirmed', payment_status: 'paid') }

      it 'cancels booking and sets payment status to refund_pending' do
        expect(booking.cancel_by_admin!('refund_pending')).to be true
        expect(booking.reload.status).to eq('cancelled')
        expect(booking.payment_status).to eq('refund_pending')
      end

      it 'can set payment status to refunded' do
        expect(booking.cancel_by_admin!('refunded')).to be true
        expect(booking.reload.status).to eq('cancelled')
        expect(booking.payment_status).to eq('refunded')
      end

      it 'returns false if booking is already cancelled' do
        cancelled_booking = create(:booking, :cancelled)
        expect(cancelled_booking.cancel_by_admin!('refund_pending')).to be false
      end
    end
  end

  describe '#calculate_total_amount' do
    let(:car) { create(:car, daily_price: 100, weekly_price: 600, monthly_price: 2500) }

    context 'when selected_period is daily' do
      it 'calculates total based on daily price' do
        booking = build(:booking, :daily, car: car,
                        start_date: Date.today,
                        end_date: Date.today + 3.days,
                        selected_price: car.daily_price)
        expect(booking.calculate_total_amount).to eq(300) # 3 days * 100
      end
    end

    context 'when selected_period is weekly' do
      it 'calculates total with full weeks and remaining days' do
        booking = build(:booking, :weekly, car: car,
                        start_date: Date.today,
                        end_date: Date.today + 10.days, # 1 week + 3 days
                        selected_price: car.weekly_price)
        expect(booking.calculate_total_amount).to eq(900) # (1 * 600) + (3 * 100)
      end
    end

    context 'when selected_period is monthly' do
      it 'calculates total with full months and remaining days' do
        booking = build(:booking, :monthly, car: car,
                        start_date: Date.today,
                        end_date: Date.today + 35.days, # 1 month + 5 days
                        selected_price: car.monthly_price)
        expect(booking.calculate_total_amount).to eq(3000) # (1 * 2500) + (5 * 100)
      end
    end

    context 'when selected_period is 5 hours (With Driver)' do
      let(:chauffeur_car) { create(:car, with_driver: true, five_hours_charge: 500, ten_hours_charge: 900, luggage_capacity: 2) }

      it 'calculates total based on fixed 5 hours charge' do
        booking = build(:booking, car: chauffeur_car,
                        start_date: Date.today,
                        end_date: Date.today,
                        selected_period: '5 Hours',
                        selected_price: chauffeur_car.five_hours_charge)
        expect(booking.calculate_total_amount).to eq(500)
      end
    end

    context 'when selected_period is 10 hours (With Driver)' do
      let(:chauffeur_car) { create(:car, with_driver: true, five_hours_charge: 500, ten_hours_charge: 900, luggage_capacity: 2) }

      it 'calculates total based on fixed 10 hours charge' do
        booking = build(:booking, car: chauffeur_car,
                        start_date: Date.today,
                        end_date: Date.today,
                        selected_period: '10 Hours',
                        selected_price: chauffeur_car.ten_hours_charge)
        expect(booking.calculate_total_amount).to eq(900)
      end
    end

    it 'returns 0 if car is not present' do
      booking = build(:booking, car: nil)
      expect(booking.calculate_total_amount).to eq(0)
    end
  end

  describe 'callbacks' do
    describe 'after_create' do
      it 'sets car vendor' do
        vendor = create(:vendor)
        car = create(:car, vendor: vendor)
        booking = create(:booking, car: car, vendor: nil)

        expect(booking.reload.vendor_id).to eq(vendor.id)
      end

      it 'logs booking created activity' do
        # Create all dependencies outside the expect block to avoid counting their activities
        user = create(:user, :with_approved_documents)
        vendor = create(:vendor)
        car = create(:car, vendor: vendor)

        expect {
          create(:booking, user: user, car: car, vendor: vendor)
        }.to change(Activity, :count).by(1)

        activity = Activity.last
        expect(activity.action).to eq('booking_created')
      end

      it 'populates total amount' do
        car = create(:car, daily_price: 100)
        booking = create(:booking, :daily, car: car,
                         start_date: Date.today,
                         end_date: Date.today + 2.days,
                         selected_price: car.daily_price)

        expect(booking.reload.total_amount).to eq(200)
      end
    end

    describe 'after_update' do
      it 'logs booking status change when status changes' do
        booking = create(:booking, status: 'pending')

        expect {
          booking.update(status: 'confirmed')
        }.to change(Activity, :count).by(1)

        activity = Activity.last
        expect(activity.action).to eq('booking_confirmed')
      end

      it 'does not log activity when status does not change' do
        booking = create(:booking, status: 'pending')

        expect {
          booking.update(start_date: Date.tomorrow)
        }.not_to change(Activity, :count)
      end
    end
  end

  describe '#populate_total_amount' do
    it 'updates total_amount without running validations' do
      car = create(:car, daily_price: 150)
      booking = create(:booking, :daily, car: car,
                       start_date: Date.today,
                       end_date: Date.today + 5.days,
                       selected_price: car.daily_price)

      expect(booking.total_amount).to eq(750)
    end
  end
end
