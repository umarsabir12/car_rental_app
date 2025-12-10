class Vendors::BookingsController < ApplicationController
  before_action :authenticate_vendor!
  before_action :set_booking, only: [ :show, :update, :update_payment_status, :update_booking_status ]

  def index
    # Get all bookings for cars belonging to the current vendor
    @bookings = Booking.includes(:user, :car)
                       .where(car_id: current_vendor.cars.pluck(:id))
                       .order(created_at: :desc)

    # Apply filters
    @bookings = @bookings.where(status: params[:status]) if params[:status].present?
    @bookings = @bookings.where(payment_processed: params[:payment_status] == "paid") if params[:payment_status].present?

    # Search by user name or email
    if params[:search].present?
      @bookings = @bookings.joins(:user)
                           .where("users.first_name ILIKE ? OR users.last_name ILIKE ? OR users.email ILIKE ?",
                                  "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%")
    end

    # Filter by car
    @bookings = @bookings.where(car_id: params[:car_id]) if params[:car_id].present?

    # Date range filter
    if params[:start_date].present?
      @bookings = @bookings.where("start_date >= ?", params[:start_date])
    end
    if params[:end_date].present?
      @bookings = @bookings.where("end_date <= ?", params[:end_date])
    end

    # Pagination (optional)
    @bookings = @bookings.page(params[:page]).per(20) if defined?(Kaminari)

    # Get cars for filter dropdown
    @cars = current_vendor.cars.order(:brand, :model)
  end

  def show
    @booking = Booking.includes(:user, :car)
                      .where(car_id: current_vendor.cars.pluck(:id))
                      .find(params[:id])
  end

  def update
    @booking = set_booking

    if @booking.update(booking_params)
      redirect_to vendors_booking_path(@booking), notice: "Booking updated successfully."
    else
      render :show
    end
  end

  # Update booking status via AJAX
  def update_booking_status
    new_status = params[:status]

    # Validate status
    valid_statuses = [ "pending", "confirmed", "cancelled" ]
    unless valid_statuses.include?(new_status)
      return respond_to do |format|
        format.json { render json: { success: false, message: "Invalid status" }, status: :unprocessable_entity }
        format.html { redirect_to vendors_booking_path(@booking), alert: "Invalid status" }
      end
    end

    if @booking.update!(status: new_status)
      respond_to do |format|
        format.json { render json: { success: true, message: "Booking status updated", status: new_status }, status: :ok }
        format.html { redirect_to vendors_booking_path(@booking), notice: "Booking status updated to #{new_status}" }
      end
    else
      respond_to do |format|
        format.json { render json: { success: false, message: "Failed to update status" }, status: :unprocessable_entity }
        format.html { render :show }
      end
    end
  end

  # Update payment status via AJAX
  def update_payment_status
    payment_status = params[:payment_status]

    # Validate payment status
    unless [ "true", "false", true, false ].include?(payment_status)
      return respond_to do |format|
        format.json { render json: { success: false, message: "Invalid payment status" }, status: :unprocessable_entity }
        format.html { redirect_to vendors_booking_path(@booking), alert: "Invalid payment status" }
      end
    end

    # Convert to boolean
    is_paid = payment_status.to_s == "true"

    if @booking.update(payment_processed: is_paid)
      status_text = is_paid ? "Paid" : "Pending"
      respond_to do |format|
        format.json {
          render json: {
            success: true,
            message: "Payment status updated to #{status_text}",
            payment_processed: is_paid,
            payment_status_text: status_text
          }, status: :ok
        }
        format.html { redirect_to vendors_booking_path(@booking), notice: "Payment status updated to #{status_text}" }
      end
    else
      respond_to do |format|
        format.json { render json: { success: false, message: "Failed to update payment status" }, status: :unprocessable_entity }
        format.html { render :show }
      end
    end
  end

  private

  def set_booking
    @booking = Booking.includes(:user, :car)
                      .where(car_id: current_vendor.cars.pluck(:id))
                      .find(params[:id])
  end

  def booking_params
    params.require(:booking).permit(:status)
  end
end
