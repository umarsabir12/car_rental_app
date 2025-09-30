class Admin::BookingsController < ApplicationController
  layout "admin"
  before_action :authenticate_admin!

  def index
    @bookings = Booking.includes(:user, car: :vendor).all
    # Add filter logic here if needed
  end

  def show
    @booking = Booking.includes(:user, :vendor, car: :vendor).find(params[:id])
    @vendors = Vendor.all.order(:company_name)
    
    # Set vendor to car's owner if not already assigned
    if @booking.vendor_id.blank? && @booking.car&.vendor
      @booking.update_column(:vendor_id, @booking.car.vendor_id)
      @booking.reload
    end
  end

  def update
    @booking = Booking.find(params[:id])
    if @booking.update(booking_params)
      redirect_to admin_booking_path(@booking), notice: 'Vendor assignment updated successfully.'
    else
      @vendors = Vendor.all.order(:company_name)
      flash.now[:alert] = 'Failed to update vendor assignment.'
      render :show
    end
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

  private

  def booking_params
    params.require(:booking).permit(:vendor_id)
  end
end 