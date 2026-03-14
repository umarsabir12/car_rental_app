class CarRentalController < ApplicationController
  def index
    @max_cards = request.user_agent&.downcase&.include?("mobile") ? 1 : 4
    # Set default dates
    @pick_date = Date.current.strftime("%Y-%m-%d")
    @drop_date = (Date.current + 3.days).strftime("%Y-%m-%d")

    # Locations data
    @locations = AppConstants::LOCATIONS

    @car_categories = AppConstants::CAR_CATEGORIES
    @car_brands = normalize_filter_values(Car.distinct.pluck(:brand).compact).map { |b| [ b, b ] }
    @car_models = normalize_filter_values(Car.distinct.pluck(:model).compact).map { |m| [ m, m ] }

    # Featured cars data (manually selected by admin)
    @featured_cars = Car.with_images_and_variants.featured.limit(10)

    # Brands data
    @brands = [
      { name: "BMW", image_url: "https://cdn.worldvectorlogo.com/logos/bmw.svg" },
      { name: "Audi", image_url: "https://cdn.worldvectorlogo.com/logos/audi-2009.svg" },
      { name: "Mercedes", image_url: "https://cdn.worldvectorlogo.com/logos/mercedes-benz-9.svg" },
      { name: "Toyota", image_url: "https://cdn.worldvectorlogo.com/logos/toyota-6.svg" }
    ]

    # Fetch Google reviews (with fallback to static testimonials)
    @testimonials = GoogleReviewsService.fetch_reviews

    # Fallback to static testimonials if Google reviews are unavailable
    if @testimonials.blank?
      @testimonials = AppConstants::SAMPLE_TESTIMONIALS
    end

    # Stats data
    @stats = AppConstants::STATISTICS

    # Company info
    @company = AppConstants::COMPANY_INFO

    # Contact info
    @contact = AppConstants::CONTACT_INFO

    # Set paths (adjust according to your routes)
    @cars_path = cars_path if respond_to?(:cars_path)

    @car_classes = AppConstants::CAR_CLASSES

    # Use centralized brand mapping from Car model (slug, name, image under app/assets/images/brands)
    @brand_logos = Car.brand_logos

    @categories_to_display = AppConstants::CATEGORIES_TO_DISPLAY

    # Fetch all category cars in ONE query instead of 4 separate queries.
    # We gather up to 12 per category by fetching more and partitioning in Ruby.
    all_categories = [ "SUV", "Luxury", "Sports", "Economy" ]
    category_pool = Car.with_images_and_variants
                   .with_approved_mulkiya
                   .where(category: all_categories)
                   .order(bookings_count: :desc, created_at: :desc)

    @category_cars = all_categories.flat_map do |category|
      category_pool.select { |car| car.category == category }.first(12)
    end

    # Fetch cars with driver
    cars_with_driver = Car.with_images_and_variants
                      .with_approved_mulkiya
                      .where(with_driver: true)
                      .order(bookings_count: :desc, created_at: :desc)
                      .limit(12)

    # Needs to be formatted similarly to category cars if we want to use the same loop in view,
    # but the view logic filters by category name/slug.
    # So we can hack it by appending a 'virtual' category or handling it in the view.
    # A cleaner approach for the view loop is to make sure these cars match the 'with_driver' slug check.
    # Since 'with_driver' isn't a category column value, we need to adjust the view or this array.
    # simpler: just add them to @category_cars and we update the view logic to filter correctly.

    @category_cars += cars_with_driver

    # Preload discounts for all cars displayed on the homepage to prevent N+1 queries
    Discount.preload_for_cars(@category_cars + @featured_cars)

    @company_features = AppConstants::COMPANY_FEATURES

    @faqs = AppConstants::FAQ_CONTENT
  end

  def terms
  end
end
