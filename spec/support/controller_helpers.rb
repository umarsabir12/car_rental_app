module ControllerHelpers
  def sign_in_user(user = nil)
    @user = user || create(:user)
    sign_in @user
    @user
  end

  def sign_in_vendor(vendor = nil)
    @vendor = vendor || create(:vendor)
    sign_in @vendor
    @vendor
  end

  def sign_in_admin(admin = nil)
    @admin = admin || create(:admin)
    sign_in @admin
    @admin
  end
end

RSpec.configure do |config|
  config.include ControllerHelpers, type: :controller
  config.include ControllerHelpers, type: :request
end
