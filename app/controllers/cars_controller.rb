class CarsController < ApplicationController
  def index
    @car_models = Car.distinct.pluck(:model).compact.map { |m| [m.titleize, m] }
    @car_brands = Car.distinct.pluck(:brand).compact.map { |b| [b.titleize, b] }

    # Only show cars with approved mulkiya documents
    @cars = Car.with_approved_mulkiya
    

    if params[:category].present?
      @selected_category = params[:category]
      @cars = @cars.where(category: @selected_category)
    end

    if params[:brand].present?
      @selected_brand = params[:brand]
      @cars = Car.filter_by_brand(@cars, @selected_brand)
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
    
    @recommended_cars = Car.with_approved_mulkiya.where.not(id: @car.id).where(featured: true).limit(4)
  end
end