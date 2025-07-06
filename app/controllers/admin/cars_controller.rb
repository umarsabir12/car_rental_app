class Admin::CarsController < ApplicationController
  layout "admin"

  def index
    @cars = Car.all
    @cars = @cars.where("model ILIKE ?", "%#{params[:model]}%") if params[:model].present?
    @cars = @cars.where("brand ILIKE ?", "%#{params[:vendor]}%") if params[:vendor].present?
    @cars = @cars.where(year: params[:year]) if params[:year].present?
    @cars = @cars.where(status: params[:status]) if params[:status].present?
  end

  def show
    @car = Car.find(params[:id])
  end
end 