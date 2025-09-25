class CarsController < ApplicationController
  def index
    @cars = Car.all

    if params[:category].present?
      @selected_category = params[:category]
      @cars = @cars.where(category: @selected_category)
    end

    if params[:brand].present?
      @selected_brand = params[:brand]
      @cars = Car.filter_by_brand(@cars, @selected_brand)
    end

    if params[:with_driver].present?
      # Accept truthy values like '1', 'true', 'yes'
      truthy = %w[1 true yes].include?(params[:with_driver].to_s.downcase)
      @with_driver = truthy
      @cars = @cars.where(with_driver: true) if truthy
    end

    @cars = @cars.order(created_at: :desc)
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