class AdminController < ApplicationController
  before_action :authenticate_admin_user!
  

  def dashboard
    @stats = {
      users: 1245,
      bookings: 87,
      vendors: 12,
      cars: 34
    }
    @recent_activity = [
      { name: 'Alice Smith', action: 'Booked a car', date: '2024-06-01' },
      { name: 'Bob Johnson', action: 'Registered as user', date: '2024-06-02' },
      { name: 'Speedy Rentals', action: 'Added a new car', date: '2024-06-03' }
    ]    
  end

end 