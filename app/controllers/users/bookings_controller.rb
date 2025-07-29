class Users::BookingsController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @bookings = current_user.bookings.includes(:car)
    if (msg = current_user.document_alert_message)
      flash.now[:alert] = msg
    end
  end
end
