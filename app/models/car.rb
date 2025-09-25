class Car < ApplicationRecord
  belongs_to :vendor, optional: true
  has_many_attached :images
  has_one_attached :mulkiya
  has_many :bookings
  after_create :create_stripe_product, :create_stripe_price
  validates :mulkiya, presence: { message: 'is required for all cars' }
  validates :images, presence: { message: 'at least one image is required' }
  validate :mulkiya_presence_on_create, on: :create
  validate :mulkiya_content_type
  validate :images_presence_on_create, on: :create

  scope :available, -> { where(status: 'available') }
  def full_name
    "#{brand} #{model} (#{year})"
  end

  def with_driver?
    with_driver == true
  end

  def booking_status
    if bookings.any?
      bookings.exists?(['start_date <= ? AND end_date >= ?', Date.today, Date.today]) ? 'rented' : 'available'
    else
      'available'
    end
  end

  # Returns true if the car is available for the entire period starting at start_date
  # period_type: 'daily' | 'weekly' | 'monthly'
  def available_for_period?(start_date, period_type)
    return false if start_date.blank?

    days_to_check = case period_type
                    when 'daily' then 1
                    when 'weekly' then 7
                    when 'monthly' then 30
                    else 1
                    end

    period_start = start_date.to_date
    period_end = period_start + (days_to_check - 1).days

    overlapping = bookings.where.not(status: 'cancelled').where(
      '(start_date, end_date) OVERLAPS (?, ?)', period_start, period_end
    )

    overlapping.none?
  end

  BRAND_LOGOS = [
    { slug: 'mitsubishi',   name: 'Mitsubishi',   image: 'car_logo/logo_0000_pngwing.com-(32).png' },
    { slug: 'rolls-royce',  name: 'Rolls-Royce',  image: 'logo_0001_pngwing.com-(31).png' },
    { slug: 'aston-martin', name: 'Aston Martin', image: 'car_logo/logo_0002_pngwing.com-(30).png' },
    { slug: 'bentley',      name: 'Bentley',      image: 'car_logo/logo_0003_pngwing.com-(29).png' },
    { slug: 'lamborghini',  name: 'Lamborghini',  image: 'car_logo/logo_0004_pngwing.com-(28).png' },
    { slug: 'mini',         name: 'Mini',         image: 'car_logo/logo_0005_pngwing.com-(27).png' },
    { slug: 'chevrolet',    name: 'Chevrolet',    image: 'car_logo/logo_0006_pngwing.com-(26).png' },
    { slug: 'lexus',        name: 'Lexus',        image: 'car_logo/logo_0007_pngwing.com-(25).png' },
    { slug: 'kia',          name: 'Kia',          image: 'car_logo/logo_0008_pngwing.com-(24).png' },
    { slug: 'cadillac',     name: 'Cadillac',     image: 'car_logo/logo_0009_pngwing.com-(23).png' },
    { slug: 'gmc',          name: 'GMC',          image: 'car_logo/logo_0009_pngwing.com-(23).png' },
    { slug: 'audi',         name: 'Audi',         image: 'car_logo/logo_0011_Layer-4.png' },
    { slug: 'mazda',        name: 'Mazda',        image: 'car_logo/logo_0012_Layer-3.png' },
    { slug: 'land-rover',   name: 'Land Rover',   image: 'car_logo/logo_0013_Layer-2.png' },
    { slug: 'nissan',       name: 'Nissan',       image: 'car_logo/logo_0014_hd-nissan-emblem-logo-transparent-png-701751694774302g4gilafdjp.png' },
    { slug: 'bmw',          name: 'BMW',          image: 'car_logo/logo_0015_Layer-1.png' }
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
    if column_names.include?('brand_slug')
      scope.where('lower(brand_slug) = ? OR lower(brand) = ?', s, s)
    else
      scope.where('lower(brand) = ?', s)
    end
  end

  private

  def images_presence_on_create
    if new_record? && images.attached? == false
      errors.add(:images, 'at least one image must be uploaded before creating the car')
    end
  end

  def mulkiya_presence_on_create
    if new_record? && !mulkiya.attached?
      errors.add(:mulkiya, 'must be uploaded before creating the car')
    end
  end

  def mulkiya_content_type
    return unless mulkiya.attached?

    allowed_types = [
      'application/pdf',
      'image/jpeg',
      'image/jpg',
      'image/png',
      'image/webp',
      'image/heic',
      'image/heif',
      'image/heic-sequence',
      'image/heif-sequence'
    ]

    unless allowed_types.include?(mulkiya.content_type)
      errors.add(:mulkiya, 'must be a PDF or an image (JPEG, PNG, WEBP)')
    end
  end

  def create_stripe_product
    return if stripe_product_id.present?
    
    product = Stripe::Product.create(
      name: full_name,
      description: description,
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
      unit_amount: self.daily_price.to_i * 100,
      currency: 'usd'
    )

    update(stripe_price_id: stripe_price.id)
  end
end