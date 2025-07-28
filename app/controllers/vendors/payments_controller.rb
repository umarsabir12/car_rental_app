class Vendors::PaymentsController < ApplicationController
  before_action :authenticate_vendor!

  def index
    # Get all paid bookings for cars belonging to the current vendor
    @paid_bookings = Booking.includes(:user, :car)
                            .where(car_id: current_vendor.cars.pluck(:id))
                            .where(payment_processed: true)
                            .order(created_at: :desc)

    # Apply filters
    @paid_bookings = @paid_bookings.where(status: params[:status]) if params[:status].present?
    
    # Search by user name or email
    if params[:search].present?
      @paid_bookings = @paid_bookings.joins(:user)
                                     .where("users.first_name ILIKE ? OR users.last_name ILIKE ? OR users.email ILIKE ?", 
                                            "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%")
    end

    # Filter by car
    @paid_bookings = @paid_bookings.where(car_id: params[:car_id]) if params[:car_id].present?

    # Date range filter
    if params[:start_date].present?
      @paid_bookings = @paid_bookings.where("start_date >= ?", params[:start_date])
    end
    if params[:end_date].present?
      @paid_bookings = @paid_bookings.where("end_date <= ?", params[:end_date])
    end

    # Calculate earnings
    @total_earnings = calculate_total_earnings(@paid_bookings)
    @monthly_earnings = calculate_monthly_earnings
    @pending_payments = calculate_pending_payments

    # Get cars for filter dropdown
    @cars = current_vendor.cars.order(:brand, :model)
  end

  def show
    @booking = Booking.includes(:user, :car)
                      .where(car_id: current_vendor.cars.pluck(:id))
                      .where(payment_processed: true)
                      .find(params[:id])
    
    # Calculate payment details
    @payment_details = calculate_payment_details(@booking)
  end

  private

  def calculate_total_earnings(bookings)
    bookings.sum do |booking|
      if booking.car.price
        total_days = (booking.end_date - booking.start_date).to_i
        booking.car.price * total_days
      else
        0
      end
    end
  end

  def calculate_monthly_earnings
    current_month_bookings = Booking.includes(:car)
                                   .where(car_id: current_vendor.cars.pluck(:id))
                                   .where(payment_processed: true)
                                   .where(created_at: Time.current.beginning_of_month..Time.current.end_of_month)
    
    calculate_total_earnings(current_month_bookings)
  end

  def calculate_pending_payments
    pending_bookings = Booking.includes(:car)
                              .where(car_id: current_vendor.cars.pluck(:id))
                              .where(payment_processed: false)
    
    calculate_total_earnings(pending_bookings)
  end

  def calculate_payment_details(booking)
    return {} unless booking.car.price

    total_days = (booking.end_date - booking.start_date).to_i
    daily_rate = booking.car.price
    total_amount = daily_rate * total_days

    {
      daily_rate: daily_rate,
      total_days: total_days,
      total_amount: total_amount,
      payment_date: booking.updated_at,
      payment_method: 'Online Payment' # This could be enhanced with actual payment method data
    }
  end
end 