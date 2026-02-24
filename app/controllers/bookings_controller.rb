class BookingsController < ApplicationController
  before_action :authenticate_user!, only: [ :create, :thank_you ]

  def create
    @booking = Booking.new(booking_params)
    @booking.user_id = current_user.id
    @booking.payment_processed = false
    @booking.payment_mode = "Online"

    # Store discount percentage at booking time (if applicable)
    if @booking.car.has_discount?
      @booking.discount_percentage = @booking.car.discount_percentage
    end

    if @booking.save
      redirect_to thank_you_bookings_path, notice: "Booking created! Please complete your payment."
    else
      # Redirect back to car show page with error message
      redirect_to car_path(@booking.car_id), alert: @booking.errors.full_messages.join(", ")
    end
  end

  def thank_you
  end

  private

  def booking_params
    params.require(:booking).permit(:car_id, :start_date, :end_date, :selected_period, :selected_price,
                                    :selected_mileage_limit, :delivery_option)
  end
end
