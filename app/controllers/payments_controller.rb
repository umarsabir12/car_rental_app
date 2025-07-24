class PaymentsController < ApplicationController
  before_action :authenticate_user!

  def show
    @booking = current_user.bookings.find(params[:id])
    @car = @booking.car
  end

  def create
    @booking = current_user.bookings.find(params[:booking_id])
    @booking.update(payment_processed: true, status: 'confirmed')
    redirect_to user_home_path, notice: 'Payment successful! Your booking is now confirmed.'
  end
end 