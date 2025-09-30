class Booking < ApplicationRecord
  belongs_to :car
  belongs_to :user
  belongs_to :vendor, optional: true
  has_many :activities, as: :subject, dependent: :destroy
  
  # Enum for payment mode
  enum payment_mode: { Cash: 0, Online: 1 }, _default: :Online
  
  validates :car_id, :user_id, :start_date, :end_date, :selected_period, presence: true
  validate :end_date_after_start_date
  validate :no_overlapping_bookings

  # payment_processed is a boolean attribute

  scope :active, -> {where("start_date > ?", Date.today)}
  
  after_create :set_car_vendor, :log_booking_created
  after_update :log_booking_status_change, if: :saved_change_to_status?
  
  private

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?

    if end_date <= start_date
      errors.add(:end_date, "must be after start date")
    end
  end

  def no_overlapping_bookings
    return if car_id.blank? || start_date.blank? || end_date.blank?

    overlapping = Booking.where(car_id: car_id)
                        .where(payment_processed: true)  # Only confirmed bookings
                        .where.not(id: id) # Exclude current booking when updating
                        .where("(start_date <= ? AND end_date >= ?) OR (start_date <= ? AND end_date >= ?) OR (start_date >= ? AND end_date <= ?)",
                               end_date, start_date, start_date, start_date, start_date, end_date)

    if overlapping.exists?
      errors.add(:base, "This car is already booked for the selected dates")
    end
  end

  def log_booking_created
    Activity.log_activity(
      user: user,
      subject: self,
      action: 'booking_created',
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

  def calculate_total_amount
    return 0 unless car.daily_price
    days = (end_date - start_date).to_i
    car.daily_price * days
  end

  def set_car_vendor
    # Set the vendor to the car's owner when booking is created
    if car&.vendor && vendor_id.blank?
      update_column(:vendor_id, car.vendor_id)
    end
  end
end 