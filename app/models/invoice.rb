class Invoice < ApplicationRecord
  belongs_to :vendor

  PAYMENT_STATUSES = %w[pending paid overdue cancelled].freeze
  BILLING_TYPES = %w[daily weekly monthly].freeze

  validates :due_date, presence: true
  validates :payment_status, inclusion: { in: PAYMENT_STATUSES }
  validates :billing_type, inclusion: { in: BILLING_TYPES }
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :from_date, :to_date, presence: true
  validate :to_date_after_from_date

  scope :pending, -> { where(payment_status: 'pending') }
  scope :paid, -> { where(payment_status: 'paid') }
  scope :overdue, -> { where(payment_status: 'overdue') }
  scope :recent, -> { order(created_at: :desc) }

  def overdue?
    payment_status == 'pending' && due_date < Date.today
  end

  def mark_as_paid!
    update(payment_status: 'paid')
  end

  private

  def to_date_after_from_date
    return if from_date.blank? || to_date.blank?

    if to_date < from_date
      errors.add(:to_date, "must be after from date")
    end
  end
end
