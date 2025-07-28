class Vendors::CarsController < ApplicationController
  before_action :authenticate_vendor!
  before_action :set_car, only: [:show, :edit, :update, :destroy]

  def index
    @cars = current_vendor.cars
  end

  def show
    @bookings = @car.bookings.includes(:user)
  end

  def new
    @car = current_vendor.cars.build
  end

  def create
    @car = current_vendor.cars.build(car_params)
    if @car.save
      redirect_to vendors_car_path(@car), notice: 'Car was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @car.update(car_params)
      redirect_to vendors_car_path(@car), notice: 'Car was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @car.destroy
    redirect_to vendors_cars_path, notice: 'Car was successfully deleted.'
  end

  private
    def set_car
      @car = current_vendor.cars.find(params[:id])
    end

    def car_params
      params.require(:car).permit(
        :model, :brand, :category, :color, :year, :price, :status, :description,
        :transmission, :fuel_type, :seats, :mileage, :engine_size,
        :air_conditioning, :gps, :sunroof, :bluetooth, :usb_ports, :featured,
        :main_image_url, images: []
      )
    end
end 