class CarsController < ApplicationController

    def index
        @cars = Car.available
        @cars = @cars.where("model ILIKE ?", "%#{params[:model]}%") if params[:model].present?
        @cars = @cars.where("brand ILIKE ?", "%#{params[:brand]}%") if params[:brand].present?
        @cars = @cars.where(year: params[:year]) if params[:year].present?
        @cars = @cars.where(category: params[:category]) if params[:category].present?
        @cars = @cars.where(with_driver: true) if params[:with_driver] == 'true'
        @cars = @cars.where(with_driver: false) if params[:with_driver] == 'false'
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
        
        @recommended_cars = Car.where.not(id: @car.id).where(featured: true).limit(4)
    end
end 