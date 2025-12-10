class Admin::DashboardController < ApplicationController
  layout "admin"
  before_action :authenticate_admin!

  def index
    @stats = {
      users: User.count,
      bookings: Booking.count,
      vendors: Vendor.active.count,
      cars: Car.count
    }

    # Load recent activities for dashboard
    @recent_user_activities = Activity.user_activities.includes(:user, :subject).recent.limit(5)
    @recent_vendor_activities = Activity.vendor_activities.includes(:vendor, :subject).recent.limit(5)
    @latest_activities = Activity.includes(:user, :vendor, :subject).recent.limit(10)
  end
end
