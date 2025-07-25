class Admin::BookingsController < ApplicationController
  layout "admin"
  before_action :authenticate_admin!

  def index
    @bookings = Booking.includes(:user, car: :vendor).all
    # Add filter logic here if needed
  end

  def show
    @booking = Booking.includes(:user, car: :vendor).find(params[:id])
  end

  def download_report
    require 'csv'
    @bookings = Booking.includes(:user, car: :vendor).all
    csv_data = CSV.generate(headers: true) do |csv|
      csv << ["ID", "User", "Car", "Vendor", "Start Date", "End Date", "Status", "Payment Processed", "Created At"]
      @bookings.each do |booking|
        csv << [
          booking.id,
          booking.user&.email,
          booking.car&.model,
          booking.car&.vendor&.name,
          booking.start_date,
          booking.end_date,
          booking.status,
          booking.payment_processed,
          booking.created_at
        ]
      end
    end
    send_data csv_data, filename: "bookings_report_#{Date.today}.csv"
  end
end 