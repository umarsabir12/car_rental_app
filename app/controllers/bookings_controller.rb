class BookingsController < ApplicationController
  before_action :authenticate_user!, only: [:create]

  def create
    @booking = Booking.new(booking_params)
    @booking.user_id = current_user.id
    @booking.payment_processed = false
    
    if @booking.save
      redirect_to  user_home_path, notice: 'Booking created! Please complete your payment.'
    else
      # Redirect back to car show page with error message
      redirect_to car_path(params[:booking][:car_id]), alert: @booking.errors.full_messages.join(', ')
    end
  end

  private
  def booking_params
    params.require(:booking).permit(:car_id, :start_date, :end_date, :payment_mode, :selected_period, :selected_price, :selected_mileage_limit)
  end
end 