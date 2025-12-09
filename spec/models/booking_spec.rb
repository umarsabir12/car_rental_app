require 'rails_helper'

RSpec.describe Booking, type: :model do
  describe 'associations' do
    it { should belong_to(:car).counter_cache(true) }
    it { should belong_to(:user) }
    it { should belong_to(:vendor).optional }
    it { should have_many(:activities).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:car_id) }
    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:start_date) }
    it { should validate_presence_of(:end_date) }
    it { should validate_presence_of(:selected_period) }

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
