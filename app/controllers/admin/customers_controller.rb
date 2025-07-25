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

  def download_report
    require 'csv'
    @users = User.all
    csv_data = CSV.generate(headers: true) do |csv|
      csv << ["ID", "Name", "Email", "Phone", "Created At"]
      @users.each do |user|
        csv << [user.id, "#{user.first_name} #{user.last_name}", user.email, user.phone, user.created_at]
      end
    end
    send_data csv_data, filename: "customers_report_ #{Date.today}.csv"
  end
end 