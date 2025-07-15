class Admin::CustomersController < ApplicationController
  layout "admin"
  before_action :authenticate_admin!

  def index
    @users = User.all
    @users = @users.where("first_name ILIKE ? OR last_name ILIKE ?", "%#{params[:name]}%", "%#{params[:name]}%") if params[:name].present?
    @users = @users.where("email ILIKE ?", "%#{params[:email]}%") if params[:email].present?
    @users = @users.where("phone ILIKE ?", "%#{params[:phone]}%") if params[:phone].present?
  end

  def show
    @user = User.find(params[:id])
  end
end 