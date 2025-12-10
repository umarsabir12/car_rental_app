# app/controllers/webhooks_controller.rb
class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def stripe
    p "stripe webhook received"
    payload = request.body.read
    sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
    endpoint_secret = Rails.application.credentials.dig(:stripe, :webhook_secret) || ENV["STRIPE_WEBHOOK_SECRET"]

    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, endpoint_secret
      )
    rescue JSON::ParserError => e
      render json: { error: "Invalid payload" }, status: 400
      return
    rescue Stripe::SignatureVerificationError => e
      render json: { error: "Invalid signature" }, status: 400
      return
    end

    case event["type"]
    # Existing booking/checkout handlers
    when "checkout.session.completed"
      handle_checkout_session_completed(event["data"]["object"])
    when "payment_intent.succeeded"
      handle_payment_intent_succeeded(event["data"]["object"])
    when "payment_intent.payment_failed"
      handle_payment_intent_failed(event["data"]["object"])

    # NEW: Invoice payment handlers
    when "charge.refunded"
      handle_charge_refunded(event["data"]["object"])
    when "payment_intent.canceled"
      handle_payment_intent_canceled(event["data"]["object"])
    end

    render json: { received: true }
  end

  private

  # ===== EXISTING BOOKING HANDLERS (unchanged) =====

  def handle_checkout_session_completed(session)
    booking_id = session["metadata"]["booking_id"]
    booking = Booking.find(booking_id)

    # Update booking
    booking.update(
      payment_processed: true,
      status: "confirmed",
      stripe_session_id: session["id"]
    )

    # Create transaction record
    Transaction.create_from_checkout_session(session)

    # Log payment activity
    Activity.log_activity(
      user: booking.user,
      subject: booking,
      action: "payment_completed",
      description: "#{booking.user.full_name} completed payment for booking ##{booking.id}",
      metadata: {
        amount: session["amount_total"],
        currency: session["currency"],
        stripe_session_id: session["id"]
      },
      request: request
    )
  end

  def handle_payment_intent_succeeded(payment_intent)
    # NEW: Check if this is an invoice payment first
    invoice = find_invoice_by_payment_intent(payment_intent["id"])

    if invoice
      handle_invoice_payment_succeeded(invoice)
      return
    end

    # EXISTING: Find booking by payment intent ID (keep original logic)
    booking = Booking.find_by(stripe_payment_intent_id: payment_intent["id"])

    if booking
      booking.update(
        payment_processed: true,
        status: "confirmed"
      )

      # Create transaction record
      Transaction.create_from_payment_intent(payment_intent)
    end
  end

  def handle_payment_intent_failed(payment_intent)
    # NEW: Check if this is an invoice payment first
    invoice = find_invoice_by_payment_intent(payment_intent["id"])

    if invoice
      handle_invoice_payment_failed(invoice, payment_intent)
      return
    end

    # EXISTING: Find booking by payment intent ID (keep original logic)
    booking = Booking.find_by(stripe_payment_intent_id: payment_intent["id"])

    if booking
      booking.update(status: "payment_failed")

      # Create failed transaction record
      Transaction.create_from_failed_payment(payment_intent)

      # Log payment failure activity
      Activity.log_activity(
        user: booking.user,
        subject: booking,
        action: "payment_failed",
        description: "#{booking.user.full_name}'s payment failed for booking ##{booking.id}",
        metadata: {
          amount: payment_intent["amount"],
          currency: payment_intent["currency"],
          stripe_payment_intent_id: payment_intent["id"],
          failure_reason: payment_intent["last_payment_error"]&.dig("message")
        },
        request: request
      )
    end
  end

  # ===== NEW: INVOICE PAYMENT HANDLERS =====

  def handle_invoice_payment_succeeded(invoice)
    # Mark invoice as paid
    invoice.mark_as_paid!

    # Log activity
    Activity.create!(
      vendor_id: invoice.vendor_id,
      subject: invoice,
      action: "payment_received",
      description: "Invoice ##{invoice.id} payment received from Vendor: #{invoice.vendor.name}",
      metadata: {
        invoice_id: invoice.id,
        amount: invoice.amount,
        currency: "aed",
        stripe_payment_intent_id: invoice.stripe_payment_intent_id,
        paid_at: Time.current
      }
    )

    Rails.logger.info("Invoice ##{invoice.id} marked as paid via Stripe webhook")
  end

  def handle_invoice_payment_failed(invoice, payment_intent)
    # Log activity
    Activity.create!(
      vendor_id: invoice.vendor_id,
      subject: invoice,
      action: "payment_failed",
      description: "Payment failed for Invoice ##{invoice.id}",
      metadata: {
        invoice_id: invoice.id,
        amount: invoice.amount,
        currency: "aed",
        stripe_payment_intent_id: invoice.stripe_payment_intent_id,
        failure_reason: payment_intent["last_payment_error"]&.dig("message")
      }
    )

    Rails.logger.warn("Payment failed for Invoice ##{invoice.id}: #{payment_intent['last_payment_error']&.dig('message')}")
  end

  def handle_charge_refunded(charge)
    # Find the invoice associated with this charge
    payment_intent_id = charge["payment_intent"]

    return unless payment_intent_id.present?

    begin
      payment_intent = Stripe::PaymentIntent.retrieve(payment_intent_id)
      invoice = find_invoice_by_payment_intent(payment_intent_id)

      return unless invoice.present?

      # Update invoice status to cancelled
      invoice.update(payment_status: "cancelled")

      # Send refund notification email
      refund_amount = charge["amount_refunded"] / 100.0

      # Log activity
      Activity.create!(
        vendor_id: invoice.vendor_id,
        subject: invoice,
        action: "payment_refunded",
        description: "Invoice ##{invoice.id} refunded: AED #{refund_amount}",
        metadata: {
          invoice_id: invoice.id,
          refund_amount: refund_amount,
          stripe_charge_id: charge["id"],
          original_amount: invoice.amount
        }
      )

      Rails.logger.info("Invoice ##{invoice.id} refunded: AED #{refund_amount}")
    rescue Stripe::StripeError => e
      Rails.logger.error("Error processing refund: #{e.message}")
    end
  end

  def handle_payment_intent_canceled(payment_intent)
    # Check if this is an invoice payment
    invoice = find_invoice_by_payment_intent(payment_intent["id"])

    return unless invoice.present?

    # Log activity
    Activity.create!(
      vendor_id: invoice.vendor_id,
      subject: invoice,
      action: "payment_cancelled",
      description: "Payment cancelled for Invoice ##{invoice.id}",
      metadata: {
        invoice_id: invoice.id,
        stripe_payment_intent_id: payment_intent["id"],
        cancellation_reason: payment_intent["cancellation_reason"]
      }
    )

    Rails.logger.info("Payment cancelled for Invoice ##{invoice.id}")
  end

  # ===== HELPER METHODS =====

  def find_invoice_by_payment_intent(payment_intent_id)
    Invoice.find_by(stripe_payment_intent_id: payment_intent_id) if payment_intent_id.present?
  end
end
