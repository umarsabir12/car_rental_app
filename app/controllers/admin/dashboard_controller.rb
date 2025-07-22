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
    @recent_activity = [
      { name: 'Alice Smith', action: 'Booked a car', date: '2024-06-01' },
      { name: 'Bob Johnson', action: 'Registered as user', date: '2024-06-02' },
      { name: 'Speedy Rentals', action: 'Added a new car', date: '2024-06-03' }
    ]    
  end
end 