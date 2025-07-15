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
    @car = Car.find(params[:id])
  end
end 