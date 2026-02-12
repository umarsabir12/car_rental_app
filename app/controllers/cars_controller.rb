class CarsController < ApplicationController
  before_action :redirect_query_params, only: [ :index ]
  before_action :normalize_filter_params, only: [ :index ]

  def index
    # Prepare filter options for initial page load
    @car_categories = Car.distinct.pluck(:category).compact.sort
    @car_brands = Car.distinct.pluck(:brand).compact.sort
    @car_models = Car.distinct.pluck(:model).compact.sort

    # Only show cars with approved mulkiya documents
    @cars = Car.with_approved_mulkiya.includes(:vendor)

    # Apply filters
    @cars = apply_filters(@cars)

    # Prepare monthly price slabs
    @max_monthly_price = Car.max_effective_monthly_price
    @min_monthly_price = Car.min_effective_monthly_price
    @monthly_price_slabs = prepare_monthly_price_slabs(@min_monthly_price, @max_monthly_price)

    # Keep for backward compatibility with old views
    @selected_category = @category
    @selected_brand = @brand
    @selected_model = @model

    @cars = @cars.order(created_at: :desc)

    set_meta_tags
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

  def search_cars
    query = params[:query].to_s.strip

    if query.length < 2
      render json: { results: [] }
      return
    end

    # Search in brand, model, and year columns
    results = Car.with_approved_mulkiya
      .where(
        "LOWER(brand) LIKE :query OR LOWER(model) LIKE :query OR CAST(year AS TEXT) LIKE :query",
        query: "%#{query.downcase}%"
      )
      .select(:brand, :model, :year, :category)
      .distinct
      .order(:year, :brand, :model)
      .limit(20)
      .map do |car|
        {
          brand: car.brand,
          model: car.model,
          year: car.year,
          category: car.category,
          display_text: "#{car.brand} #{car.model} #{car.year}"
        }
      end

    render json: { results: results }
  end

  def show
    @car = Car.includes(:bookings, :features, :vendor).friendly.find(params[:id])
    @booking_success = flash[:notice] if flash[:notice].present?

    @booked_dates = @car.bookings
      .select(:start_date, :end_date)
      .flat_map { |b| (b.start_date..b.end_date).to_a }
      .uniq
      .map(&:to_s)
      .sort

    @recommended_cars = [ "SUV", "Luxury", "Sports" ].flat_map do |category|
      Car.with_approved_mulkiya
         .includes(:vendor)
         .where(category: category)
         .left_joins(:bookings)
         .select("cars.*, COUNT(bookings.id) as total_bookings")
         .group("cars.id")
         .order("total_bookings DESC, cars.created_at DESC")
         .limit(4)
    end
  end

  private

  def get_filtered_categories(brand, model)
    query = Car.with_approved_mulkiya
    query = query.where(brand: brand) if brand.present?
    query = query.where("LOWER(model) = ?", model.downcase) if model.present?
    query.distinct.pluck(:category).compact.sort
  end

  def get_filtered_brands(category, model)
    query = Car.with_approved_mulkiya
    query = query.where(category: category) if category.present?
    query = query.where("LOWER(model) = ?", model.downcase) if model.present?
    query.distinct.pluck(:brand).compact.sort
  end

  def get_filtered_models(category, brand)
    query = Car.with_approved_mulkiya
    query = query.where(category: category) if category.present?
    query = query.where(brand: brand) if brand.present?
    query.distinct.pluck(:model).compact.sort
  end

  def normalize_filter_params
    if params[:category] == "with-driver"
      @with_driver = true
      @category = nil
    else
      @category = params[:category] == "all-categories" ? nil : find_actual_category(params[:category])
    end
    @brand = params[:brand] == "all-brands" ? nil : find_actual_brand(params[:brand])
    @model = params[:model] == "all-models" ? nil : find_actual_model(params[:model])
    @monthly_price = params[:monthly_price]
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
    value.split("-").map(&:capitalize).join(" ")
  end

  def apply_filters(cars)
    if @with_driver
      cars = cars.where(with_driver: true)
    elsif @category.present?
      cars = cars.where(category: @category)
    end
    cars = Car.filter_by_brand(cars, @brand) if @brand.present?
    cars = cars.where("LOWER(model) = ?", @model.downcase) if @model.present?
    cars = Car.filter_by_monthly_price(cars, params[:monthly_price] || @monthly_price) if (params[:monthly_price] || @monthly_price).present?
    cars
  end

  def prepare_monthly_price_slabs(min_price, max_price)
    return [] if max_price <= 0

    slabs = []
    # Start from the floor of the minimum price (e.g., 1055 -> 1000)
    current = (min_price / 100).floor * 100

    while current <= max_price
      next_limit = current + 100
      slabs << [ "#{current} - #{next_limit}", "#{current}-#{next_limit}" ]
      current = next_limit
    end
    slabs
  end

  def redirect_query_params
    category = request.query_parameters[:category]
    brand = request.query_parameters[:brand]
    model = request.query_parameters[:model]
    monthly_price = request.query_parameters[:monthly_price]

    if category.present? || brand.present? || model.present? || monthly_price.present?
      # Calculate remaining parameters to keep them in the URL, but exclude blanks and 'commit'
      remaining_params = request.query_parameters
        .except(:category, :brand, :model, :monthly_price, :commit)
        .select { |_, v| v.present? }

      clean_url = build_clean_url(category, brand, model, monthly_price)

      # Append remaining params if any
      if remaining_params.any?
        uri = URI.parse(clean_url)
        new_query = URI.decode_www_form(uri.query || "").to_h.merge(remaining_params)
        uri.query = URI.encode_www_form(new_query)
        clean_url = uri.to_s
      end

      redirect_to clean_url, status: :moved_permanently
    end
  end

  def build_clean_url(category, brand, model, monthly_price = nil)
    parts = []

    if monthly_price.present?
      parts << (category.present? ? category.parameterize : "all-categories")
      parts << (brand.present? ? brand.parameterize : "all-brands")
      parts << (model.present? ? model.parameterize : "all-models")
      parts << monthly_price
    elsif model.present?
      parts << (category.present? ? category.parameterize : "all-categories")
      parts << (brand.present? ? brand.parameterize : "all-brands")
      parts << model.parameterize
    elsif brand.present?
      parts << (category.present? ? category.parameterize : "all-categories")
      parts << brand.parameterize
    elsif category.present?
      parts << category.parameterize
    end

    parts.empty? ? cars_path : "/cars/#{parts.join('/')}"
  end

  def set_meta_tags
    @meta_title = "Car Rental Dubai | Affordable Car Hire - Wheels on Rent"
    @meta_description = "Rent cars in Dubai with best prices, daily & monthly plans, and a wide range of vehicles at Wheels on Rent."

    return if params[:category].blank? && params[:brand].blank? && params[:model].blank?

    meta_tags = find_meta_tags_for_filters
    return unless meta_tags

    @meta_title, @meta_description = meta_tags.values_at(:title, :description)
  end

  def find_meta_tags_for_filters
    AppConstants::CAR_CATEGORIES_META[params[:category]&.downcase] ||
    AppConstants::CAR_BRANDS_META[params[:brand]&.downcase]
  end
end
