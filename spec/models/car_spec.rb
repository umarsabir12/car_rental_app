require 'rails_helper'

RSpec.describe Car, type: :model do
  describe 'associations' do
    it { should belong_to(:vendor).optional }
    it { should have_many(:bookings) }
    it { should have_one(:car_document).dependent(:destroy) }
    it { should have_many(:activities).dependent(:destroy) }
    it { should have_many(:car_features).dependent(:destroy) }
    it { should have_many(:features).through(:car_features) }
  end

  describe 'validations' do
    subject { build(:car) }

    it { should validate_presence_of(:images).with_message('at least one image is required') }
    it { should validate_presence_of(:insurance_policy) }

    describe 'images_presence_on_create' do
      it 'requires at least one image on create' do
        car = build(:car)
        car.images.purge
        expect(car).not_to be_valid
        expect(car.errors[:images]).to include('at least one image must be uploaded before creating the car')
      end
    end
  end

  describe 'scopes' do
    describe '.available' do
      let!(:available_car) { create(:car, status: 'available') }
      let!(:unavailable_car) { create(:car, status: 'unavailable') }

      it 'returns only available cars' do
        expect(Car.available).to include(available_car)
        expect(Car.available).not_to include(unavailable_car)
      end
    end

    describe '.with_approved_mulkiya' do
      let!(:car_with_approved) { create(:car, :with_approved_document) }
      let!(:car_without_document) { create(:car) }

      it 'returns only cars with approved car documents' do
        expect(Car.with_approved_mulkiya).to include(car_with_approved)
        expect(Car.with_approved_mulkiya).not_to include(car_without_document)
      end
    end
  end

  describe '#full_name' do
    it 'returns brand, model and year combined' do
      car = build(:car, brand: 'BMW', model: 'X5', year: 2023)
      expect(car.full_name).to eq('BMW X5 (2023)')
    end
  end

  describe '#booking_status' do
    let(:car) { create(:car) }

    context 'when car has no bookings' do
      it 'returns available' do
        expect(car.booking_status).to eq('available')
      end
    end

    context 'when car has current booking' do
      before do
        create(:booking, car: car,
               start_date: Date.yesterday,
               end_date: Date.tomorrow,
               payment_processed: true)
      end

      it 'returns rented' do
        expect(car.booking_status).to eq('rented')
      end
    end

    context 'when car has only future bookings' do
      before do
        create(:booking, car: car,
               start_date: Date.tomorrow,
               end_date: Date.tomorrow + 5.days,
               payment_processed: true)
      end

      it 'returns available' do
        expect(car.booking_status).to eq('available')
      end
    end
  end

  describe '#available_for_period?' do
    let(:car) { create(:car) }

    context 'when period is daily' do
      it 'returns true if no overlapping bookings' do
        expect(car.available_for_period?(Date.tomorrow, 'daily')).to be true
      end

      it 'returns false if period overlaps with existing booking' do
        create(:booking, car: car,
               start_date: Date.tomorrow,
               end_date: Date.tomorrow + 3.days,
               payment_processed: true)

        expect(car.available_for_period?(Date.tomorrow, 'daily')).to be false
      end
    end

    context 'when period is weekly' do
      it 'checks 7 days availability' do
        start_date = Date.today + 10.days
        expect(car.available_for_period?(start_date, 'weekly')).to be true
      end
    end

    context 'when period is monthly' do
      it 'checks 30 days availability' do
        start_date = Date.today + 10.days
        expect(car.available_for_period?(start_date, 'monthly')).to be true
      end
    end
  end

  describe '.brand_logos' do
    it 'returns array of brand hashes' do
      expect(Car.brand_logos).to be_an(Array)
      expect(Car.brand_logos.first).to have_key(:slug)
      expect(Car.brand_logos.first).to have_key(:name)
      expect(Car.brand_logos.first).to have_key(:image)
    end
  end

  describe '.find_brand_by_slug' do
    it 'finds brand by slug' do
      brand = Car.find_brand_by_slug('BMW')
      expect(brand).not_to be_nil
      expect(brand[:name]).to eq('BMW')
    end

    it 'returns nil for non-existent slug' do
      brand = Car.find_brand_by_slug('NonExistent')
      expect(brand).to be_nil
    end
  end

  describe '.filter_by_brand' do
    let!(:bmw_car) { create(:car, brand: 'BMW') }
    let!(:audi_car) { create(:car, brand: 'Audi') }

    it 'filters cars by brand name' do
      results = Car.filter_by_brand(Car.all, 'BMW')
      expect(results).to include(bmw_car)
      expect(results).not_to include(audi_car)
    end

    it 'is case insensitive' do
      results = Car.filter_by_brand(Car.all, 'bmw')
      expect(results).to include(bmw_car)
    end

    it 'returns all cars if filter is blank' do
      results = Car.filter_by_brand(Car.all, nil)
      expect(results).to include(bmw_car, audi_car)
    end
  end

  describe 'FriendlyId' do
    it 'generates slug from brand and model' do
      car = create(:car, brand: 'BMW', model: 'X5', year: 2023)
      expect(car.slug).to eq('bmw-x5')
    end

    it 'regenerates slug when brand or model changes' do
      car = create(:car, brand: 'BMW', model: 'X5')
      car.update(model: 'X7')
      expect(car.slug).to eq('bmw-x7')
    end
  end

  describe 'callbacks' do
    describe 'after_create' do
      it 'logs car added activity' do
        vendor = create(:vendor)
        expect {
          create(:car, vendor: vendor)
        }.to change(Activity, :count).by(1)

        activity = Activity.last
        expect(activity.action).to eq('car_added')
      end

      it 'creates common features associations' do
        create(:feature, :common, name: 'Insurance')
        car = create(:car)

        expect(car.features.where(common: true).count).to be > 0
      end
    end

    describe 'after_update' do
      it 'logs car updated activity when relevant fields change' do
        vendor = create(:vendor)
        car = create(:car, vendor: vendor, brand: 'BMW')

        expect {
          car.update(brand: 'Audi')
        }.to change(Activity, :count).by(1)

        activity = Activity.last
        expect(activity.action).to eq('car_updated')
      end
    end

    describe 'before_destroy' do
      it 'logs car deleted activity' do
        vendor = create(:vendor)
        car = create(:car, vendor: vendor)

        # Verify the log_car_deleted method is called
        expect(car).to receive(:log_car_deleted).and_call_original
        car.destroy
      end

      it 'purges attached images' do
        car = create(:car)
        expect(car.images).to be_attached

        car.destroy
        expect(car.images).not_to be_attached
      end
    end
  end

  describe '#active_features' do
    it 'returns humanized names of true feature columns' do
      car = build(:car, air_conditioning: true, gps: true, sunroof: false, bluetooth: false)
      expect(car.active_features).to match_array(['Air conditioning', 'Gps'])
    end

    it 'returns empty array if no features are active' do
      car = build(:car, air_conditioning: false, gps: false, sunroof: false, bluetooth: false)
      expect(car.active_features).to be_empty
    end
  end
end
