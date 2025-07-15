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
end 