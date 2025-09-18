class Booking < ApplicationRecord
  belongs_to :car
  belongs_to :user
  
  # Enum for payment mode
  enum payment_mode: { Cash: 0, Online: 1 }, _default: :Online
  
  validates :car_id, :user_id, :start_date, :end_date, presence: true
  validate :end_date_after_start_date
  validate :no_overlapping_bookings

  # payment_processed is a boolean attribute

  scope :active, -> {where("start_date > ?", Date.today)}
  
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
end 