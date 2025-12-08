class Admin::AnalyticsController < ApplicationController
    layout "admin"
    before_action :authenticate_admin!

    def index
      # Cache summary metrics for 15 minutes
      @total_bookings = Rails.cache.fetch('analytics/total_bookings', expires_in: 15.minutes) do
        Booking.count
      end

      @monthly_revenue = Rails.cache.fetch("analytics/monthly_revenue/#{Date.today.strftime('%Y-%m')}", expires_in: 1.hour) do
        Booking.where('created_at >= ?', Time.current.beginning_of_month).sum(:total_amount)
      end

      @available_cars_count = Rails.cache.fetch('analytics/available_cars_count', expires_in: 5.minutes) do
        Car.where(status: 'available').count
      end

      @total_cars_count = Rails.cache.fetch('analytics/total_cars_count', expires_in: 15.minutes) do
        Car.count
      end

      @new_customers_count = Rails.cache.fetch("analytics/new_customers/#{Date.today}", expires_in: 1.hour) do
        User.where('created_at >= ?', 1.week.ago).count
      end

      # Cache top booked cars for 30 minutes
      @top_cars = Rails.cache.fetch('analytics/top_cars', expires_in: 30.minutes) do
        Car.joins(:bookings)
           .select('cars.*, COUNT(bookings.id) as bookings_count, SUM(bookings.total_amount) as total_revenue')
           .group('cars.id')
           .order('COUNT(bookings.id) DESC')
           .limit(5)
           .to_a
      end

      # Cache top vendors for 30 minutes
      @top_vendors = Rails.cache.fetch('analytics/top_vendors', expires_in: 30.minutes) do
        Vendor.joins(cars: :bookings)
              .select('vendors.*, COUNT(DISTINCT cars.id) as cars_count, SUM(bookings.total_amount) as total_revenue, MAX(bookings.created_at) as last_booking_date')
              .group('vendors.id')
              .order('SUM(bookings.total_amount) DESC')
              .limit(5)
              .to_a
      end
    end
end