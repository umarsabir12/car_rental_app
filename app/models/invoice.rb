# app/models/invoice.rb
class Invoice < ApplicationRecord
  belongs_to :vendor
  has_many :invoice_items, dependent: :destroy
  accepts_nested_attributes_for :invoice_items, allow_destroy: true, reject_if: :all_blank

  PAYMENT_STATUSES = %w[pending paid cancelled overdue].freeze
  PAYMENT_MODES = %w[Online].freeze

  # Set default payment mode
  after_initialize :set_default_payment_mode, if: :new_record?

  validates :payment_mode, inclusion: { in: PAYMENT_MODES }
  validates :payment_status, inclusion: { in: PAYMENT_STATUSES }
  validates :amount, presence: true, numericality: { greater_than: 0 }

  scope :pending, -> { where(payment_status: "pending") }
  scope :paid, -> { where(payment_status: "paid") }
  scope :recent, -> { order(created_at: :desc) }
  scope :overdue, -> { where(payment_status: "overdue") }

  # Create Stripe PaymentIntent for invoice
  def create_stripe_intent
    return if stripe_payment_intent_id.present?

    intent = Stripe::PaymentIntent.create(
      amount: (amount * 100).to_i, # Amount in cents
      currency: "aed",
      metadata: {
        invoice_id: id,
        vendor_id: vendor_id,
        vendor_email: vendor.email,
        invoice_number: id
      },
      description: "Invoice ##{id} - #{vendor.company_name}"
    )

    update(stripe_payment_intent_id: intent.id)
    intent
  rescue Stripe::StripeError => e
    Rails.logger.error("Stripe error creating payment intent: #{e.message}")
    raise e
  end

  # Retrieve existing PaymentIntent
  def stripe_intent
    return nil unless stripe_payment_intent_id.present?
    Stripe::PaymentIntent.retrieve(stripe_payment_intent_id)
  rescue Stripe::StripeError => e
    Rails.logger.error("Stripe error retrieving payment intent: #{e.message}")
    nil
  end

  # Confirm payment and update status
  def confirm_payment(payment_method_id = nil)
    intent = stripe_intent
    return false unless intent

    # If payment method is provided, attach it
    if payment_method_id.present?
      intent = Stripe::PaymentIntent.update(
        intent.id,
        payment_method: payment_method_id
      )
    end

    # Confirm the payment intent
    intent = Stripe::PaymentIntent.confirm(intent.id)

    # Update invoice based on intent status
    case intent.status
    when "succeeded"
      mark_as_paid!
      true
    when "requires_action"
      false
    else
      false
    end
  rescue Stripe::StripeError => e
    Rails.logger.error("Stripe error confirming payment: #{e.message}")
    false
  end

  # Mark invoice as paid
  def mark_as_paid!
    update(
      payment_status: "paid",
      paid_at: Time.current
    )
  end

  # Calculate total from line items
  def calculate_total
    invoice_items.sum(:amount)
  end

  # Formatted amount for display
  def formatted_amount
    "AED #{amount.to_i}"
  end

  # Check if payment can be processed
  def can_process_payment?
    payment_status == "pending" || payment_status == "overdue"
  end

  private

  def set_default_payment_mode
    self.payment_mode ||= "Online"
  end
end
