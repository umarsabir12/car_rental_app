class Booking < ApplicationRecord
  belongs_to :car, counter_cache: true
  belongs_to :user
  belongs_to :vendor, optional: true
  has_many :activities, as: :subject, dependent: :destroy

  # Enum for payment mode
  enum payment_mode: { Cash: 0, Online: 1 }, _default: :Online

  # Constants
  DELIVERY_CHARGE = 50.0
  # Booking statuses (separate from payment)
  STATUSES = %w[pending confirmed cancelled].freeze
  # Payment statuses
  PAYMENT_STATUSES = %w[pending paid unpaid refunded refund_pending].freeze

  validates :car_id, :user_id, :start_date, :end_date, :selected_period, presence: true
  validates :delivery_option, inclusion: { in: %w[delivery pickup], allow_blank: true }
  validates :status, inclusion: { in: STATUSES }
  validates :payment_status, inclusion: { in: PAYMENT_STATUSES }
  validate :end_date_after_start_date
  validate :no_overlapping_bookings

  # payment_processed is a boolean attribute (deprecated - use payment_status)

  scope :active, -> { where("start_date > ?", Date.today) }
  scope :paid, -> { where(payment_status: "paid") }
  scope :unpaid, -> { where(payment_status: %w[pending unpaid]) }

  after_create :set_car_vendor, :log_booking_created, :populate_total_amount
  after_update :log_booking_status_change, if: :saved_change_to_status?

  def calculate_total_amount
    return 0 unless car && start_date && end_date

    duration_days = (end_date - start_date).to_i
    daily_price = car.daily_price.to_f

    # Calculate base amount using original prices (selected_price stores original price)
    base_amount = case selected_period
    when "weekly"
                    weekly_price = selected_price.to_f
                    full_weeks = duration_days / 7
                    remaining_days = duration_days % 7
                    (full_weeks * weekly_price) + (remaining_days * daily_price)

    when "monthly"
                    monthly_price = selected_price.to_f
                    full_months = duration_days / 30
                    remaining_days = duration_days % 30
                    (full_months * monthly_price) + (remaining_days * daily_price)

    when "5 Hours", "10 Hours"
                    selected_price.to_f

    else # daily
                    duration_days * selected_price.to_f
    end

    # Apply discount if stored in booking (uses stored discount_percentage)
    if has_discount?
      discount_amount = base_amount * (discount_percentage / 100.0)
      base_amount = base_amount - discount_amount
    end

    # Add delivery or pickup charge if applicable
    base_amount += delivery_charge if delivery_charge_applicable?

    base_amount
  end

  # Get discount information for this booking
  def applicable_discount
    @applicable_discount ||= car&.applicable_discount
  end

  def has_discount?
    # Use stored discount_percentage if available, otherwise check car's current discount
    self[:discount_percentage].present? && self[:discount_percentage] > 0
  end

  def discount_percentage
    # Use stored discount_percentage (preserves discount even if removed from car later)
    self[:discount_percentage] || 0
  end

  def discount_amount
    return 0 unless has_discount?

    original_amount = calculate_total_amount_without_discount
    original_amount * (discount_percentage / 100.0)
  end

  def calculate_total_amount_without_discount
    return 0 unless car && start_date && end_date

    duration_days = (end_date - start_date).to_i
    daily_price = car.daily_price.to_f

    # Get original prices from car (not selected_price which may be discounted)
    weekly_price = car.weekly_price.to_f
    monthly_price = car.monthly_price.to_f

    base_amount = case selected_period
    when "weekly"
                    full_weeks = duration_days / 7
                    remaining_days = duration_days % 7
                    (full_weeks * weekly_price) + (remaining_days * daily_price)

    when "monthly"
                    full_months = duration_days / 30
                    remaining_days = duration_days % 30
                    (full_months * monthly_price) + (remaining_days * daily_price)

    when "5 Hours"
                    car.five_hours_charge.to_f

    when "10 Hours"
                    car.ten_hours_charge.to_f

    else # daily
                    duration_days * daily_price
    end

    base_amount
  end

  def delivery_charge_applicable?
    delivery_option.present? && %w[delivery pickup].include?(delivery_option)
  end

  def delivery_charge
    delivery_charge_applicable? ? DELIVERY_CHARGE : 0
  end

  def populate_total_amount
    self.total_amount = calculate_total_amount
    save(validate: false)
  end

  # Check if booking is cancelled
  def cancelled?
    status == "cancelled"
  end

  # Check if payment needs refund
  def needs_refund?
    payment_status.in?(%w[refunded refund_pending])
  end

  # Check if booking was cancelled and needs/has refund
  def cancelled_with_refund?
    cancelled? && needs_refund?
  end

  # Cancel booking and set appropriate payment refund status
  def cancel_by_admin!(refund_status = "refund_pending")
    return false unless %w[pending confirmed].include?(status)

    update(status: "cancelled", payment_status: refund_status)
  end

  # Check if payment is completed
  def payment_completed?
    payment_status == "paid"
  end

  private

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?

    errors.add(:end_date, "must be after start date") if end_date < start_date
  end

  def no_overlapping_bookings
    return if car_id.blank? || start_date.blank? || end_date.blank?

    overlapping = Booking.where(car_id: car_id, payment_processed: true) # Only confirmed bookings
                         .where.not(id: id) # Exclude current booking when updating
                         .where("(start_date <= ? AND end_date >= ?) OR (start_date <= ? AND end_date >= ?) OR (start_date >= ? AND end_date <= ?)",
                                end_date, start_date, start_date, start_date, start_date, end_date)

    errors.add(:base, "This car is already booked for the selected dates") if overlapping.exists?
  end

  def log_booking_created
    Activity.log_activity(
      user: user,
      subject: self,
      action: "booking_created",
      description: "#{user.full_name} created a booking for #{car.brand} #{car.model}",
      metadata: {
        car_id: car_id,
        start_date: start_date,
        end_date: end_date,
        total_amount: calculate_total_amount
      }
    )
  end

  def log_booking_status_change
    Activity.log_activity(
      user: user,
      subject: self,
      action: "booking_#{status}",
      description: "Booking ##{id} status changed to #{status}",
      metadata: {
        previous_status: status_before_last_save,
        new_status: status,
        car: "#{car.brand} #{car.model}"
      }
    )
  end

  def set_car_vendor
    # Set the vendor to the car's owner when booking is created
    update_column(:vendor_id, car.vendor_id) if car&.vendor && vendor_id.blank?
  end
end
