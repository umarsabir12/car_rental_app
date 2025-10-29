class CarsController < ApplicationController
  before_action :redirect_query_params, only: [:index]
  before_action :normalize_filter_params, only: [:index]

  def index
    @car_models = Car.distinct.pluck(:model).compact.map { |m| [m.capitalize, m] }
    @car_brands = Car.distinct.pluck(:brand).compact.map { |b| [b.capitalize, b] }

    # Only show cars with approved mulkiya documents
    @cars = Car.with_approved_mulkiya
  
    # Apply filters
    @cars = apply_filters(@cars)

    # Keep for backward compatibility with old views
    @selected_category = @category
    @selected_brand = @brand
    @selected_model = @model

    @cars = @cars.order(created_at: :desc)
  end

  def show
    @car = Car.friendly.find(params[:id])  # Changed this line
    @booking_success = flash[:notice] if flash[:notice].present?
    
    @booked_dates = @car.bookings.where.not(status: 'cancelled')
      .flat_map { |b| (b.start_date..b.end_date).to_a }
      .uniq
      .map(&:to_s)
      .sort
    
    @recommended_cars = ['SUV', 'Luxury', 'Sports'].flat_map do |category|
      Car.with_approved_mulkiya
         .where(category: category)
         .left_joins(:bookings)
         .select('cars.*, COUNT(bookings.id) as total_bookings')
         .group('cars.id')
         .order('total_bookings DESC, cars.created_at DESC')
         .limit(4)
    end
  end

  private

  def normalize_filter_params
    # Convert placeholder values to nil
    @category = params[:category] == 'all-categories' ? nil : deparameterize(params[:category])
    @brand = params[:brand] == 'all-brands' ? nil : deparameterize(params[:brand])
    @model = find_actual_model(params[:model])
  end

  def find_actual_model(parameterized_value)
    return nil if parameterized_value.blank?
    
    # Find the actual model from database that matches the parameterized version
    Car.distinct.pluck(:model).compact.find do |model|
      model.parameterize == parameterized_value
    end || deparameterize(parameterized_value)
  end
  
  def deparameterize(value)
    return nil if value.blank?
    value.split('-').map(&:capitalize).join(' ')
  end

  def apply_filters(cars)
    # Filter by category
    if @category.present?
      cars = cars.where(category: @category)
    end
    
    # Filter by brand
    if @brand.present?
      cars = Car.filter_by_brand(cars, @brand)
    end
    
    # Filter by model
    if @model.present?
      cars = cars.where('LOWER(model) = ?', @model.downcase)
    end
    
    cars
  end

  def redirect_query_params
    # Redirect old query param URLs to clean URLs
    category = request.query_parameters[:category]
    brand = request.query_parameters[:brand]
    model = request.query_parameters[:model]
    
    if category.present? || brand.present? || model.present?
      clean_url = build_clean_url(category, brand, model)
      redirect_to clean_url, status: :moved_permanently
    end
  end

  def build_clean_url(category, brand, model)
    # Use parameterize to create URL-friendly slugs
    parts = []
    
    # Determine what we need based on what's selected
    if model.present?
      # If model is selected, we need all three parts
      parts << (category.present? ? category.parameterize : 'all-categories')
      parts << (brand.present? ? brand.parameterize : 'all-brands')
      parts << model.parameterize
    elsif brand.present?
      # If brand is selected (but not model), we need category and brand
      parts << (category.present? ? category.parameterize : 'all-categories')
      parts << brand.parameterize
    elsif category.present?
      # If only category is selected
      parts << category.parameterize
    end
    
    parts.empty? ? cars_path : "/cars/#{parts.join('/')}"
  end
end