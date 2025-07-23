class UsersController < ApplicationController
  before_action :authenticate_user!

  def home
    @user = current_user
    @bookings = @user.bookings.includes(:car)
    if (msg = @user.document_alert_message)
      flash.now[:alert] = msg
    end
  end

  def profile
    @user = current_user
  end

  def bookings
    @bookings = current_user.bookings.includes(:car)
  end

  def update_nationality
    if current_user.update!(nationality: params[:nationality])
      render json: { success: true, nationality: current_user.nationality }
    else
      render json: { success: false, errors: current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

end 