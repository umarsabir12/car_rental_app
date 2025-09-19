class Admin::DashboardController < ApplicationController
  layout "admin"
  before_action :authenticate_admin!
  
  def index
    @stats = {
      users: User.count,
      bookings: Booking.count,
      vendors: Vendor.count,
      cars: Car.count
    }
  end
end 