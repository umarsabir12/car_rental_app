class Transaction < ApplicationRecord
  belongs_to :booking

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true, inclusion: { in: %w[pending completed failed refunded] }
  validates :transaction_type, presence: true, inclusion: { in: %w[payment refund] }
  validates :stripe_payment_intent_id, presence: true, uniqueness: true, allow_blank: true
  validates :stripe_session_id, presence: true, uniqueness: true, allow_blank: true

  scope :completed, -> { where(status: "completed") }
  scope :pending, -> { where(status: "pending") }
  scope :failed, -> { where(status: "failed") }
  scope :refunded, -> { where(status: "refunded") }
  scope :payments, -> { where(transaction_type: "payment") }
  scope :refunds, -> { where(transaction_type: "refund") }
  scope :recent, -> { order(created_at: :desc) }

  def self.create_from_webhook(event_data)
    case event_data["type"]
    when "checkout.session.completed"
      create_from_checkout_session(event_data["data"]["object"])
    when "payment_intent.succeeded"
      create_from_payment_intent(event_data["data"]["object"])
    when "payment_intent.payment_failed"
      create_from_failed_payment(event_data["data"]["object"])
    end
  end

  def self.create_from_checkout_session(session)
    booking_id = session["metadata"]["booking_id"]
    booking = Booking.find(booking_id)

    create!(
      booking: booking,
      stripe_session_id: session["id"],
      stripe_payment_intent_id: session["payment_intent"],
      amount: session["amount_total"] / 100.0,
      status: "completed",
      transaction_type: "payment",
      processed_at: Time.current
    )
  end

  def self.create_from_payment_intent(payment_intent)
    booking = Booking.find_by(stripe_payment_intent_id: payment_intent["id"])
    return unless booking

    create!(
      booking: booking,
      stripe_payment_intent_id: payment_intent["id"],
      amount: payment_intent["amount"] / 100.0,
      status: "completed",
      transaction_type: "payment",
      processed_at: Time.current
    )
  end

  def self.create_from_failed_payment(payment_intent)
    booking = Booking.find_by(stripe_payment_intent_id: payment_intent["id"])
    return unless booking

    create!(
      booking: booking,
      stripe_payment_intent_id: payment_intent["id"],
      amount: payment_intent["amount"] / 100.0,
      status: "failed",
      transaction_type: "payment",
      processed_at: Time.current
    )
  end

  def refundable?
    status == "completed" && transaction_type == "payment" && refund_amount.nil?
  end

  def refund!(amount: nil, reason: nil)
    return false unless refundable?

    refund_amount_to_process = amount || self.amount

    begin
      refund = Stripe::Refund.create(
        payment_intent: stripe_payment_intent_id,
        amount: (refund_amount_to_process * 100).to_i,
        reason: "requested_by_customer"
      )

      update!(
        refund_amount: refund_amount_to_process,
        refund_reason: reason,
        status: "refunded"
      )

      # Create a refund transaction record
      Transaction.create!(
        booking: booking,
        stripe_payment_intent_id: stripe_payment_intent_id,
        amount: refund_amount_to_process,
        status: "completed",
        transaction_type: "refund",
        refund_reason: reason,
        processed_at: Time.current
      )

      true
    rescue Stripe::StripeError => e
      errors.add(:base, "Refund failed: #{e.message}")
      false
    end
  end

  def status_display
    case status
    when "completed"
      "Payment Completed"
    when "pending"
      "Payment Pending"
    when "failed"
      "Payment Failed"
    when "refunded"
      "Refunded"
    else
      status.titleize
    end
  end

  def type_display
    transaction_type.titleize
  end

  def amount_display
    if transaction_type == "refund"
      "-$#{amount}"
    else
      "$#{amount}"
    end
  end
end
