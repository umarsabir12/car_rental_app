require 'rails_helper'

RSpec.describe Admin, type: :model do
  describe 'validations' do
    subject { build(:admin) }

    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
  end

  describe 'devise modules' do
    it 'has database_authenticatable module' do
      expect(Admin.devise_modules).to include(:database_authenticatable)
    end

    it 'has registerable module' do
      expect(Admin.devise_modules).to include(:registerable)
    end

    it 'has recoverable module' do
      expect(Admin.devise_modules).to include(:recoverable)
    end

    it 'has rememberable module' do
      expect(Admin.devise_modules).to include(:rememberable)
    end

    it 'has validatable module' do
      expect(Admin.devise_modules).to include(:validatable)
    end
  end

  it 'creates valid admin' do
    admin = create(:admin)
    expect(admin).to be_valid
    expect(admin.email).to be_present
  end
end
