class Vendors::BookingsController < ApplicationController
  before_action :authenticate_vendor!

  def index
    # Get all bookings for cars belonging to the current vendor
    @bookings = Booking.includes(:user, :car)
                       .where(car_id: current_vendor.cars.pluck(:id))
                       .order(created_at: :desc)

    # Apply filters
    @bookings = @bookings.where(status: params[:status]) if params[:status].present?
    @bookings = @bookings.where(payment_processed: params[:payment_status] == 'paid') if params[:payment_status].present?
    
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
    @booking = Booking.includes(:user, :car)
                      .where(car_id: current_vendor.cars.pluck(:id))
                      .find(params[:id])
    
    if @booking.update(booking_params)
      redirect_to vendors_booking_path(@booking), notice: 'Booking status updated successfully.'
    else
      render :show
    end
  end

  private

  def booking_params
    params.require(:booking).permit(:status)
  end
end 