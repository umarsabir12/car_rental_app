class CarsController < ApplicationController

    def index
        @cars = Car.all
        @cars = @cars.where("model ILIKE ?", "%#{params[:model]}%") if params[:model].present?
        @cars = @cars.where("brand ILIKE ?", "%#{params[:brand]}%") if params[:brand].present?
        @cars = @cars.where(year: params[:year]) if params[:year].present?
        @cars = @cars.where(status: params[:status]) if params[:status].present?
    end

    def show
        @car = Car.find(params[:id])
        @booking_success = flash[:notice] if flash[:notice].present?
        # Only include confirmed/paid bookings for date blocking
        @booked_dates = @car.bookings.where.not(status: 'cancelled')
          .flat_map { |b| (b.start_date..b.end_date).to_a }
          .uniq
          .map(&:to_s)
          .sort
    end
end 