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
    respond_to do |format|
      if @booking.update(booking_params)
        format.html { redirect_to admin_booking_path(@booking), notice: "Vendor assignment updated successfully." }
      else
        @vendors = Vendor.all.order(:company_name)
        flash.now[:alert] = "Error: #{@booking.errors.full_messages.to_sentence}"
        format.html { render :show, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace('form-errors', partial: 'shared/form_errors', locals: { object: @booking }),
            turbo_stream.replace('flash-container', partial: 'shared/flash_messages')
          ]
        end
      end
    end
  end

  def cancel
    @booking = Booking.find(params[:id])
    respond_to do |format|
      if @booking.cancel_by_admin!("refund_pending")
        format.html { redirect_to admin_booking_path(@booking), notice: "Booking has been cancelled successfully. Refund is pending." }
        format.turbo_stream { redirect_to admin_booking_path(@booking), notice: "Booking has been cancelled successfully. Refund is pending." }
      else
        format.html { redirect_to admin_booking_path(@booking), alert: "Failed to cancel booking. It may already be cancelled." }
        format.turbo_stream { redirect_to admin_booking_path(@booking), alert: "Failed to cancel booking. It may already be cancelled." }
      end
    end
  end

  def update_status
    @booking = Booking.find(params[:id])
    new_status = params[:status]

    respond_to do |format|
      if Booking::STATUSES.include?(new_status) && @booking.update(status: new_status)
        format.html { redirect_to admin_booking_path(@booking), notice: "Booking status updated to #{new_status.titleize} successfully." }
        format.turbo_stream { redirect_to admin_booking_path(@booking), notice: "Booking status updated to #{new_status.titleize} successfully." }
      else
        format.html { redirect_to admin_booking_path(@booking), alert: "Failed to update booking status." }
        format.turbo_stream { redirect_to admin_booking_path(@booking), alert: "Failed to update booking status." }
      end
    end
  end

  def update_payment_status
    @booking = Booking.find(params[:id])
    new_payment_status = params[:payment_status]

    respond_to do |format|
      if Booking::PAYMENT_STATUSES.include?(new_payment_status) && @booking.update(payment_status: new_payment_status)
        format.html { redirect_to admin_booking_path(@booking), notice: "Payment status updated to #{new_payment_status.titleize} successfully." }
        format.turbo_stream { redirect_to admin_booking_path(@booking), notice: "Payment status updated to #{new_payment_status.titleize} successfully." }
      else
        format.html { redirect_to admin_booking_path(@booking), alert: "Failed to update payment status." }
        format.turbo_stream { redirect_to admin_booking_path(@booking), alert: "Failed to update payment status." }
      end
    end
  end

  def download_report
    require "csv"
    @bookings = Booking.includes(:user, car: :vendor).all
    csv_data = CSV.generate(headers: true) do |csv|
      csv << [ "ID", "User", "Car", "Vendor", "Start Date", "End Date", "Status", "Payment Processed", "Created At" ]
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
