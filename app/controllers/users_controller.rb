class UsersController < ApplicationController
  before_action :authenticate_user!

  def home
    @user = current_user
    @bookings = @user.bookings.includes(:car)
  end

  def profile
    @user = current_user
  end

  def bookings
    @bookings = current_user.bookings.includes(:car)
  end
end 