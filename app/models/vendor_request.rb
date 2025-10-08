class VendorRequest < ApplicationRecord

  enum status: { pending: 0, approved: 1, rejected: 2 }, _default: :pending

  validates :email, :first_name, :last_name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, if: :email?

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
