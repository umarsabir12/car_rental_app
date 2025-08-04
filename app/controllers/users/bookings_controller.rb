class Users::BookingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_booking, only: [:cancel]
  
  def index
    @bookings = current_user.bookings.includes(:car)
    
    # Apply filter based on params
    case params[:filter]
    when 'active'
      @bookings = @bookings.where(status: ['pending', 'confirmed'])
    when 'cancelled'
      @bookings = @bookings.where(status: 'cancelled')
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
    if @booking.status == 'pending' || @booking.status == 'confirmed'
      @booking.update(status: 'cancelled')
      redirect_to users_bookings_path, notice: 'Booking cancelled successfully.'
    else
      redirect_to users_bookings_path, alert: 'This booking cannot be cancelled.'
    end
  end

  private

  def set_booking
    @booking = current_user.bookings.find(params[:id])
  end
end
