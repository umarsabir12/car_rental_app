require 'rails_helper'

RSpec.describe InvitedVendor, type: :model do
  it 'creates valid invited vendor' do
    invited_vendor = create(:invited_vendor)
    expect(invited_vendor).to be_valid
  end
end
