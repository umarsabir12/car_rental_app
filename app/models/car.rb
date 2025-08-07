class Car < ApplicationRecord
  belongs_to :vendor, optional: true
  has_many_attached :images
  has_many :bookings
  after_create :create_stripe_product, :create_stripe_price

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
      unit_amount: self.price.to_i * 100,
      currency: 'usd'
    )

    update(stripe_price_id: stripe_price.id)
  end
end