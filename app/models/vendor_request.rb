class VendorRequest < ApplicationRecord

  enum status: { pending: 0, approved: 1, rejected: 2 }, _default: :pending

  validates :first_name, :last_name, :vehicle_count, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }

  scope :pending, -> { where(status: 'pending') }
  scope :approved, -> { where(status: 'approved') }
  scope :rejected, -> { where(status: 'rejected') }
  
  def full_name
    "#{first_name} #{last_name}"
  end

  def approve!
    update(status: 'approved')
  end
  
  def reject!
    update(status: 'rejected')
  end
end
