class Car < ApplicationRecord
  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  belongs_to :vendor, optional: true
  has_many_attached :images
  has_many :bookings
  has_one :car_document, dependent: :destroy
  has_many :activities, as: :subject, dependent: :destroy
  has_many :car_features, dependent: :destroy
  has_many :features, through: :car_features

  validates :images, presence: { message: 'at least one image is required' }
  validate :images_presence_on_create, on: :create
  validates :insurance_policy, presence: true

  FEATURE_COLUMNS = %w[air_conditioning gps sunroof bluetooth].freeze
  
  def active_features
    FEATURE_COLUMNS.select { |feature| send(feature) }.map { |feature| feature.humanize }
  end
  
  after_create :log_car_added, :create_common_features
  after_update :log_car_updated, if: :saved_change_to_brand? || :saved_change_to_model? || :saved_change_to_daily_price?
  before_destroy :log_car_deleted, :purge_attachments
  
  scope :available, -> { where(status: 'available') }
  scope :with_approved_mulkiya, -> { 
    joins(:car_document).where(car_documents: { document_status: 'approved' }) 
  }

  def full_name
    "#{brand} #{model} (#{year})"
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
    { slug: 'rolls-royce',  name: 'Rolls-Royce',  image: 'car_logo/logo_0001_pngwing.com-(31).png' },
    { slug: 'aston-martin', name: 'Aston Martin', image: 'car_logo/logo_0002_pngwing.com-(30).png' },
    { slug: 'bentley',      name: 'Bentley',      image: 'car_logo/logo_0003_pngwing.com-(29).png' },
    { slug: 'lamborghini',  name: 'Lamborghini',  image: 'car_logo/logo_0004_pngwing.com-(28).png' },
    { slug: 'mini',         name: 'Mini',         image: 'car_logo/logo_0005_pngwing.com-(27).png' },
    { slug: 'chevrolet',    name: 'Chevrolet',    image: 'car_logo/logo_0006_pngwing.com-(26).png' },
    { slug: 'lexus',        name: 'Lexus',        image: 'car_logo/logo_0007_pngwing.com-(25).png' },
    { slug: 'kia',          name: 'Kia',          image: 'car_logo/logo_0008_pngwing.com-(24).png' },
    { slug: 'cadillac',     name: 'Cadillac',     image: 'car_logo/logo_0009_pngwing.com-(23).png' },
    { slug: 'gmc',          name: 'GMC',          image: 'car_logo/logo_0010_pngwing.com-(22).png' },
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

  # Generate slug from multiple fields
  def slug_candidates
    [
      [:brand, :model],
      [:brand, :model, :year],
      [:brand, :model, :year, :category]
    ]
  end
  
  # Regenerate slug when relevant fields change
  def should_generate_new_friendly_id?
    brand_changed? || model_changed? || year_changed? || super
  end

  private

  def images_presence_on_create
    if new_record? && images.attached? == false
      errors.add(:images, 'at least one image must be uploaded before creating the car')
    end
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
      unit_amount: self.daily_price.to_i * 100,
      currency: 'usd'
    )

    update(stripe_price_id: stripe_price.id)
  end

  def log_car_added
    return unless vendor.present?
    
    Activity.log_activity(
      vendor: vendor,
      subject: self,
      action: 'car_added',
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
      action: 'car_updated',
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
      action: 'car_deleted',
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
end