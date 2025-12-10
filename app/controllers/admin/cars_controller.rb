class Admin::CarsController < ApplicationController
  layout "admin"
  before_action :authenticate_admin!

  def index
    @cars = Car.all
    @cars = @cars.where("model ILIKE ?", "%#{params[:model]}%") if params[:model].present?
    @cars = @cars.where("brand ILIKE ?", "%#{params[:vendor]}%") if params[:vendor].present?
    @cars = @cars.where(year: params[:year]) if params[:year].present?
    @cars = @cars.where(status: params[:status]) if params[:status].present?
    @cars = @cars.where(vendor_id: params[:vendor_id]) if params[:vendor_id].present?
  end

  def show
    @car = Car.friendly.find(params[:id])
    @vendor_avatar_url = url_for(@car.vendor.avatar.first)
  end

  def download_report
    require "csv"
    @cars = Car.includes(:vendor).all
    csv_data = CSV.generate(headers: true) do |csv|
      csv << [ "ID", "Brand", "Model", "Year", "Status", "Vendor", "Created At" ]
      @cars.each do |car|
        csv << [ car.id, car.brand, car.model, car.year, car.status, car.vendor&.name, car.created_at ]
      end
    end
    send_data csv_data, filename: "cars_report_#{Date.today}.csv"
  end
end
