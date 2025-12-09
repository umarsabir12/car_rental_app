require 'rails_helper'

RSpec.describe Feature, type: :model do
  describe 'associations' do
    it { should have_many(:car_features).dependent(:destroy) }
    it { should have_many(:cars).through(:car_features) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
  end

  describe 'scopes' do
    let!(:common_feature) { create(:feature, :common) }
    let!(:premium_feature) { create(:feature, :premium) }

    describe '.common' do
      it 'returns only common features' do
        expect(Feature.common).to include(common_feature)
        expect(Feature.common).not_to include(premium_feature)
      end
    end

    describe '.premium' do
      it 'returns only premium features' do
        expect(Feature.premium).to include(premium_feature)
        expect(Feature.premium).not_to include(common_feature)
      end
    end
  end

  describe 'callbacks' do
    describe 'after_create for common features' do
      it 'assigns common feature to all existing cars' do
        car1 = create(:car)
        car2 = create(:car)
        
        common_feature = create(:feature, :common)
        
        expect(car1.reload.features).to include(common_feature)
        expect(car2.reload.features).to include(common_feature)
      end
    end

    describe 'after_update when changed to common' do
      it 'assigns feature to all cars when changed from premium to common' do
        car = create(:car)
        feature = create(:feature, :premium)
        
        expect(car.features).not_to include(feature)
        
        feature.update(common: true)
        
        expect(car.reload.features).to include(feature)
      end
    end
  end
end
