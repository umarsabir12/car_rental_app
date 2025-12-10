require 'rails_helper'

RSpec.describe CarFeature, type: :model do
  describe 'associations' do
    it { should belong_to(:car) }
    it { should belong_to(:feature) }
  end

  it 'creates valid car_feature association' do
    car_feature = create(:car_feature)
    expect(car_feature).to be_valid
    expect(car_feature.car).to be_present
    expect(car_feature.feature).to be_present
  end
end
