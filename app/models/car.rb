class Car < ApplicationRecord
  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  has_many_attached :images do |attachable|
    attachable.variant :thumb, resize_to_limit: [ 400, 300 ], preprocessed: true
  end

  belongs_to :vendor, optional: true
  has_many :bookings
  has_one :car_document, dependent: :destroy
  has_many :activities, as: :subject, dependent: :destroy
  has_many :car_features, dependent: :destroy
  has_many :features, through: :car_features

  validates :images, presence: { message: "at least one image is required" }
  validate :images_presence_on_create, on: :create
  validates :insurance_policy, presence: true

  # With Driver validations
  with_options if: -> { with_driver? || category == "Limousine" } do |car|
    car.validates :five_hours_charge, presence: true, numericality: { greater_than: 0 }, unless: -> { category == "Limousine" }
    car.validates :ten_hours_charge, presence: true, numericality: { greater_than: 0 }, unless: -> { category == "Limousine" }
    car.validates :hourly_price, presence: true, numericality: { greater_than: 0 }, if: -> { category == "Limousine" }
    car.validates :luggage_capacity, presence: true, numericality: { greater_than_or_equal_to: 0 }, unless: -> { category == "Limousine" }
  end

  FEATURE_COLUMNS = %w[air_conditioning gps sunroof bluetooth].freeze

  def active_features
    FEATURE_COLUMNS.select { |feature| send(feature) }.map { |feature| feature.humanize }
  end

  after_create :log_car_added, :create_common_features
  before_save :ensure_limousine_with_driver
  after_update :log_car_updated, if: :saved_change_to_brand? || :saved_change_to_model? || :saved_change_to_daily_price?
  before_destroy :log_car_deleted, :purge_attachments

  scope :featured, -> { where(featured: true) }
  scope :available, -> { where(status: "available") }
  scope :with_approved_mulkiya, -> {
    left_joins(:car_document).where(
      "cars.with_driver = ? OR car_documents.document_status = ?",
      true, 1
    )
  }

  scope :with_images_and_variants, -> {
    with_attached_images
      .includes(images_attachments: { blob: :variant_records })
  }

  def full_name
    "#{brand} #{model} (#{year})"
  end

  def booking_status
    if bookings.any?
      bookings.exists?([ "start_date <= ? AND end_date >= ?", Date.current, Date.current ]) ? "rented" : "available"
    else
      "available"
    end
  end

  attr_writer :applicable_discount

  # Get applicable discount for this car
  def applicable_discount
    return @applicable_discount if defined?(@applicable_discount)
    @applicable_discount = Discount.applicable_for_car(self)
  end

  # Check if car has an active discount
  def has_discount?
    applicable_discount.present?
  end

  # Get discount percentage for display
  def discount_percentage
    (applicable_discount&.discount_percentage || 0).round
  end

  # Calculate discounted price
  def discounted_price(original_price)
    return 0.0 unless original_price.present? && original_price.to_f > 0
    return original_price.to_f unless has_discount?

    discount_amount = (original_price.to_f * discount_percentage / 100.0)
    original_price.to_f - discount_amount
  end

  # Get discounted daily price
  def discounted_daily_price
    discounted_price(daily_price)
  end

  # Get discounted monthly price
  def discounted_monthly_price
    discounted_price(monthly_price)
  end

  # Get discounted 5h charge
  def discounted_five_hours_charge
    discounted_price(five_hours_charge)
  end

  # Get discounted 10h charge
  def discounted_ten_hours_charge
    discounted_price(ten_hours_charge)
  end

  # Get discounted hourly price
  def discounted_hourly_price
    discounted_price(hourly_price)
  end

  # Returns true if the car is available for the entire period starting at start_date
  # period_type: 'daily' | 'weekly' | 'monthly'
  def available_for_period?(start_date, period_type)
    return false if start_date.blank?

    days_to_check = case period_type
    when "daily" then 1
    when "weekly" then 7
    when "monthly" then 30
    else 1
    end

    period_start = start_date.to_date
    period_end = period_start + (days_to_check - 1).days

    overlapping = bookings.where(
      "(start_date, end_date) OVERLAPS (?, ?)", period_start, period_end
    )

    overlapping.none?
  end

  BRAND_LOGOS = [
    { slug: "Mitsubishi",   name: "Mitsubishi",   image: "car_logo/logo_0000_pngwing.com-(32).png" },
    { slug: "Rolls Royce",  name: "Rolls-Royce",  image: "car_logo/logo_0001_pngwing.com-(31).png" },
    { slug: "Aston-Martin", name: "Aston Martin", image: "car_logo/logo_0002_pngwing.com-(30).png" },
    { slug: "Bentley",      name: "Bentley",      image: "car_logo/logo_0003_pngwing.com-(29).png" },
    { slug: "Lamborghini",  name: "Lamborghini",  image: "car_logo/logo_0004_pngwing.com-(28).png" },
    { slug: "Mini",         name: "Mini",         image: "car_logo/logo_0005_pngwing.com-(27).png" },
    { slug: "Chevrolet",    name: "Chevrolet",    image: "car_logo/logo_0006_pngwing.com-(26).png" },
    { slug: "Lexus",        name: "Lexus",        image: "car_logo/logo_0007_pngwing.com-(25).png" },
    { slug: "Kia",          name: "Kia",          image: "car_logo/logo_0008_pngwing.com-(24).png" },
    { slug: "Cadillac",     name: "Cadillac",     image: "car_logo/logo_0009_pngwing.com-(23).png" },
    { slug: "GMC",          name: "GMC",          image: "car_logo/logo_0010_pngwing.com-(22).png" },
    { slug: "Audi",         name: "Audi",         image: "car_logo/logo_0011_Layer-4.png" },
    { slug: "Mazda",        name: "Mazda",        image: "car_logo/logo_0012_Layer-3.png" },
    { slug: "Land Rover",   name: "Land Rover",   image: "car_logo/logo_0013_Layer-2.png" },
    { slug: "Nissan",       name: "Nissan",       image: "car_logo/logo_0014_hd-nissan-emblem-logo-transparent-png-701751694774302g4gilafdjp.png" },
    { slug: "BMW",          name: "BMW",          image: "car_logo/logo_0015_Layer-1.png" }
  ].freeze

  # Return array for views (use Car.brand_logos)
  def self.brand_logos
    BRAND_LOGOS
  end

  # Find brand hash by slug
  def self.find_brand_by_slug(slug)
    BRAND_LOGOS.find { |b| b[:slug].to_s == slug.to_s }
  end

  # Scope-like helper to filter cars by brand slug or name (case-insensitive).
  # Adjust column names (brand_slug / brand) to match your schema.
  def self.filter_by_brand(scope = all, slug_or_name)
    return scope unless slug_or_name.present?

    s = slug_or_name.to_s.downcase
    # If model has brand_slug column, prefer it; otherwise fallback to brand name
    if column_names.include?("brand_slug")
      scope.where("lower(brand_slug) LIKE ? OR lower(brand) LIKE ?", "%#{s}%", "%#{s}%")
    else
      scope.where("lower(brand) LIKE ?", "%#{s}%")
    end
  end

  def self.filter_by_monthly_price(scope, range_string)
    return scope if range_string.blank?

    if range_string.include?("-plus")
      min = range_string.split("-").first.to_i
      max = Float::INFINITY
    else
      min, max = range_string.split("-").map(&:to_i)
    end

    return scope unless min && max

    # Load the scoped cars once and bulk-preload discounts to prevent N+1.
    cars_scope = scope.where(with_driver: [ false, nil ])
    Discount.preload_for_cars(cars_scope)

    matching_ids = cars_scope.select do |car|
      effective_price = car.discounted_monthly_price
      effective_price >= min && effective_price < max
    end.map(&:id)

    scope.where(id: matching_ids)
  end

  def self.max_effective_monthly_price
    # Use DB-level MAX to avoid loading all cars into memory.
    # We exclude "with driver" cars as requested.
    with_approved_mulkiya
      .where(with_driver: [ false, nil ])
      .where.not(monthly_price: nil)
      .maximum(:monthly_price)
      .to_f
  end

  def self.min_effective_monthly_price
    # Use DB-level MIN to avoid loading all cars into memory.
    # We exclude "with driver" cars as requested.
    with_approved_mulkiya
      .where(with_driver: [ false, nil ])
      .where.not(monthly_price: nil)
      .minimum(:monthly_price)
      .to_f
  end

  # Generate slug from multiple fields
  def slug_candidates
    [
      [ :brand, :model ],
      [ :brand, :model, :year ],
      [ :brand, :model, :year, :category ]
    ]
  end

  # Regenerate slug when relevant fields change
  def should_generate_new_friendly_id?
    slug.blank?
  end

  private

  def images_presence_on_create
    return unless new_record? && images.attached? == false

    errors.add(:images, "at least one image must be uploaded before creating the car")
  end

  def create_stripe_product
    return if stripe_product_id.present?

    product = Stripe::Product.create(
      name: full_name,
      metadata: {
        car_id: id,
        category: category
      }
    )

    update(stripe_product_id: product.id)
  end

  def create_stripe_price
    return if stripe_price_id.present?

    stripe_price = Stripe::Price.create(
      product: stripe_product_id,
      unit_amount: daily_price.to_i * 100,
      currency: "usd"
    )

    update(stripe_price_id: stripe_price.id)
  end

  def log_car_added
    return unless vendor.present?

    Activity.log_activity(
      vendor: vendor,
      subject: self,
      action: "car_added",
      description: "#{vendor.company_name} added a new car: #{full_name}",
      metadata: {
        car_id: id,
        brand: brand,
        model: model,
        year: year,
        daily_price: daily_price
      }
    )
  end

  def log_car_updated
    return unless vendor.present?

    changes = []
    changes << "brand: #{brand_before_last_save} → #{brand}" if saved_change_to_brand?
    changes << "model: #{model_before_last_save} → #{model}" if saved_change_to_model?
    changes << "price: #{daily_price_before_last_save} → #{daily_price}" if saved_change_to_daily_price?

    Activity.log_activity(
      vendor: vendor,
      subject: self,
      action: "car_updated",
      description: "#{vendor.company_name} updated car: #{full_name} (#{changes.join(', ')})",
      metadata: {
        car_id: id,
        changes: changes
      }
    )
  end

  def log_car_deleted
    return unless vendor.present?

    Activity.log_activity(
      vendor: vendor,
      subject: self,
      action: "car_deleted",
      description: "#{vendor.company_name} deleted car: #{full_name}",
      metadata: {
        car_id: id,
        brand: brand,
        model: model,
        year: year
      }
    )
  end

  def create_common_features
    self.feature_ids = Feature.common.ids
  end

  def purge_attachments
    images.purge if images.attached?
  end

  def ensure_limousine_with_driver
    self.with_driver = true if category == "Limousine"
  end
end
