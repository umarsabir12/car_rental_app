class Car < ApplicationRecord
  belongs_to :vendor, optional: true
  has_many_attached :images
  has_one_attached :mulkiya
  has_many :bookings
  after_create :create_stripe_product, :create_stripe_price
  validate :mulkiya_presence_on_create, on: :create
  validate :mulkiya_content_type

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

  private

  def mulkiya_presence_on_create
    if new_record? && !mulkiya.attached?
      errors.add(:mulkiya, 'is required')
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