class CarsController < ApplicationController
  before_action :redirect_query_params, only: [:index]
  before_action :normalize_filter_params, only: [:index]

  def index
    # ✨ ADD THIS SECTION - Prepare filter options for initial page load
    @car_categories = Car.distinct.pluck(:category).compact.sort
    @car_brands = Car.distinct.pluck(:brand).compact.sort
    @car_models = Car.distinct.pluck(:model).compact.sort

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

  def filter_options
    category = params[:category].presence
    brand = params[:brand].presence
    model = params[:model].presence
  
    # Get available options for each filter independently
    filtered_categories = get_filtered_categories(brand, model)
    filtered_brands = get_filtered_brands(category, model)
    filtered_models = get_filtered_models(category, brand)
  
    render json: {
      filtered_brands: filtered_brands,
      filtered_models: filtered_models,
      filtered_categories: filtered_categories
    }
  end

  def show
    @car = Car.friendly.find(params[:id])
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

  def get_filtered_categories(brand, model)
    query = Car.with_approved_mulkiya
    query = query.where(brand: brand) if brand.present?
    query = query.where('LOWER(model) = ?', model.downcase) if model.present?
    query.distinct.pluck(:category).compact.sort
  end
  
  def get_filtered_brands(category, model)
    query = Car.with_approved_mulkiya
    query = query.where(category: category) if category.present?
    query = query.where('LOWER(model) = ?', model.downcase) if model.present?
    query.distinct.pluck(:brand).compact.sort
  end
  
  def get_filtered_models(category, brand)
    query = Car.with_approved_mulkiya
    query = query.where(category: category) if category.present?
    query = query.where(brand: brand) if brand.present?
    query.distinct.pluck(:model).compact.sort
  end

  def normalize_filter_params
    @category = params[:category] == 'all-categories' ? nil : find_actual_category(params[:category])
    @brand = params[:brand] == 'all-brands' ? nil : find_actual_brand(params[:brand])
    @model = find_actual_model(params[:model])
  end

  def find_actual_category(parameterized_value)
    return nil if parameterized_value.blank?
    categories = AppConstants::CAR_CATEGORIES.map(&:last)
    categories.find do |cat|
      cat.parameterize == parameterized_value
    end || deparameterize(parameterized_value)
  end

  def find_actual_brand(parameterized_value)
    return nil if parameterized_value.blank?
    Car.distinct.pluck(:brand).compact.find do |brand|
      brand.parameterize == parameterized_value
    end || deparameterize(parameterized_value)
  end

  def find_actual_model(parameterized_value)
    return nil if parameterized_value.blank?
    Car.distinct.pluck(:model).compact.find do |model|
      model.parameterize == parameterized_value
    end || deparameterize(parameterized_value)
  end
  
  def deparameterize(value)
    return nil if value.blank?
    value.split('-').map(&:capitalize).join(' ')
  end

  def apply_filters(cars)
    cars = cars.where(category: @category) if @category.present?
    cars = Car.filter_by_brand(cars, @brand) if @brand.present?
    cars = cars.where('LOWER(model) = ?', @model.downcase) if @model.present?
    cars
  end

  def redirect_query_params
    category = request.query_parameters[:category]
    brand = request.query_parameters[:brand]
    model = request.query_parameters[:model]
    
    if category.present? || brand.present? || model.present?
      clean_url = build_clean_url(category, brand, model)
      redirect_to clean_url, status: :moved_permanently
    end
  end

  def build_clean_url(category, brand, model)
    parts = []
    
    if model.present?
      parts << (category.present? ? category.parameterize : 'all-categories')
      parts << (brand.present? ? brand.parameterize : 'all-brands')
      parts << model.parameterize
    elsif brand.present?
      parts << (category.present? ? category.parameterize : 'all-categories')
      parts << brand.parameterize
    elsif category.present?
      parts << category.parameterize
    end
    
    parts.empty? ? cars_path : "/cars/#{parts.join('/')}"
  end
end