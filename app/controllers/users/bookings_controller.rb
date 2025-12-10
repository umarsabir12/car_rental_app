class Users::BookingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_booking, only: [ :cancel, :update_payment_mode ]

  def index
    @bookings = current_user.bookings.includes(:car)

    # Apply filter based on params
    case params[:filter]
    when "active"
      @bookings = @bookings.where(status: [ "pending", "confirmed" ])
    when "cancelled"
      @bookings = @bookings.where(status: "cancelled")
    else
      # 'all' or no filter - show all bookings
      @bookings = @bookings
    end

    # Order by most recent first
    @bookings = @bookings.order(created_at: :desc)

    if (msg = current_user.document_alert_message)
      flash.now[:alert] = msg
    end
  end

  def cancel
    if @booking.status == "pending" || @booking.status == "confirmed"
      @booking.update(status: "cancelled")
      redirect_to users_bookings_path, notice: "Booking cancelled successfully."
    else
      redirect_to users_bookings_path, alert: "This booking cannot be cancelled."
    end
  end

  # Update payment mode via AJAX
  def update_payment_mode
    if @booking.update(payment_mode: params[:payment_mode])
      respond_to do |format|
        format.json { render json: { success: true, message: "Payment mode updated successfully" }, status: :ok }
        format.html { redirect_to users_payment_path(@booking), notice: "Payment mode updated successfully." }
      end
    else
      respond_to do |format|
        format.json { render json: { success: false, message: "Failed to update payment mode" }, status: :unprocessable_entity }
        format.html { redirect_to users_payment_path(@booking), alert: "Failed to update payment mode." }
      end
    end
  end

  private

  def set_booking
    @booking = current_user.bookings.find(params[:id])
  end
end
