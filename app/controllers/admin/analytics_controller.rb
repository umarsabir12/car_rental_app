class Admin::AnalyticsController < ApplicationController
    layout "admin"
    before_action :authenticate_admin!

    def index
      # Summary metrics
      @total_bookings = Booking.count
      @monthly_revenue = Booking.where('created_at >= ?', Time.current.beginning_of_month).sum(:total_amount)
      @available_cars_count = Car.where(status: 'available').count
      @total_cars_count = Car.count
      @new_customers_count = User.where('created_at >= ?', 1.week.ago).count

      # Top booked cars with bookings count and revenue
      @top_cars = Car.joins(:bookings)
                     .select('cars.*, COUNT(bookings.id) as bookings_count, SUM(bookings.total_amount) as total_revenue')
                     .group('cars.id')
                     .order('COUNT(bookings.id) DESC')
                     .limit(5)

      # Top vendors by car count and total revenue
      @top_vendors = Vendor.joins(cars: :bookings)
                           .select('vendors.*, COUNT(DISTINCT cars.id) as cars_count, SUM(bookings.total_amount) as total_revenue, MAX(bookings.created_at) as last_booking_date')
                           .group('vendors.id')
                           .order('SUM(bookings.total_amount) DESC')
                           .limit(5)
    end
end