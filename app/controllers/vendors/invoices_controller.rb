# app/controllers/vendors/invoices_controller.rb
class Vendors::InvoicesController < ApplicationController
  before_action :authenticate_vendor!
  before_action :set_invoice, only: [ :show, :pay, :payment_status, :confirm_payment, :update_payment_mode ]
  before_action :set_publishable_key, only: [ :show ]

  def index
    @invoices = current_vendor.invoices.includes(:invoice_items).order(created_at: :desc)
  end

  def show
    # Set default payment mode if not set (for existing invoices)
    if @invoice.payment_mode.blank?
      @invoice.update(payment_mode: "Online")
    end
  end

  # Create Stripe PaymentIntent and return client secret
  def create_payment_intent
    @invoice = current_vendor.invoices.find(params[:invoice_id])

    unless @invoice.can_process_payment?
      render json: { error: "This invoice cannot be paid" }, status: :unprocessable_entity
      return
    end

    begin
      intent = @invoice.create_stripe_intent
      render json: { clientSecret: intent.client_secret }, status: :ok
    rescue Stripe::StripeError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  # Process payment form submission
  def pay
    unless @invoice.can_process_payment?
      redirect_to vendors_invoice_path(@invoice), alert: "This invoice has already been paid."
      return
    end

    begin
      intent = @invoice.create_stripe_intent
      @client_secret = intent.client_secret
      @publishable_key = Rails.application.credentials.dig(:stripe, :publishable_key)

      # Payment is confirmed on client-side with Stripe.js
      # This endpoint just returns the intent details
      render json: {
        clientSecret: @client_secret,
        amount: @invoice.amount,
        currency: "aed"
      }, status: :ok
    rescue Stripe::StripeError => e
      Rails.logger.error("Stripe error: #{e.message}")
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  def confirm_payment
    unless @invoice.can_process_payment?
      return render json: { error: "This invoice cannot be paid" }, status: :unprocessable_entity
    end

    begin
      payment_method_id = params[:payment_method_id]

      unless payment_method_id.present?
        return render json: { error: "Payment method is required" }, status: :unprocessable_entity
      end

      # Create PaymentIntent if it doesn't exist (NO return_url here)
      unless @invoice.stripe_payment_intent_id.present?
        Rails.logger.info("Creating PaymentIntent for invoice #{@invoice.id}")
        intent = Stripe::PaymentIntent.create(
          amount: (@invoice.invoice_items.sum(:amount) * 100).to_i,
          currency: "aed",
          metadata: {
            invoice_id: @invoice.id,
            vendor_id: @invoice.vendor_id
          }
        )
        @invoice.update(stripe_payment_intent_id: intent.id)
        Rails.logger.info("PaymentIntent created: #{intent.id}")
      end

      # Confirm with return_url (ONLY here)
      Rails.logger.info("Confirming PaymentIntent #{@invoice.stripe_payment_intent_id} with payment method #{payment_method_id}")
      intent = Stripe::PaymentIntent.confirm(
        @invoice.stripe_payment_intent_id,
        {
          payment_method: payment_method_id,
          return_url: vendors_invoice_url(@invoice)  # ← ONLY HERE
        }
      )

      Rails.logger.info("PaymentIntent status: #{intent.status}")

      case intent.status
      when "succeeded"
        @invoice.mark_as_paid!

        render json: {
          success: true,
          message: "Payment successful!",
          redirect_url: vendors_invoice_path(@invoice)
        }, status: :ok

      when "requires_action"
        render json: {
          success: false,
          clientSecret: intent.client_secret,
          requiresAction: true,
          message: "Please complete the additional authentication step"
        }, status: :ok

      else
        render json: {
          success: false,
          message: "Payment failed with status: #{intent.status}"
        }, status: :unprocessable_entity
      end

    rescue Stripe::CardError => e
      Rails.logger.warn("Card error on invoice #{@invoice.id}: #{e.message}")
      render json: { error: e.message }, status: :unprocessable_entity

    rescue Stripe::StripeError => e
      Rails.logger.error("Stripe error confirming payment on invoice #{@invoice.id}: #{e.message}")
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  # Check payment status
  def payment_status
    begin
      if @invoice.stripe_payment_intent_id.present?
        intent = Stripe::PaymentIntent.retrieve(@invoice.stripe_payment_intent_id)
        render json: {
          status: intent.status,
          invoice_status: @invoice.payment_status
        }, status: :ok
      else
        render json: { error: "No payment intent found" }, status: :not_found
      end
    rescue Stripe::StripeError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  # Update payment mode
  def update_payment_mode
    payment_mode = params[:payment_mode]

    unless Invoice::PAYMENT_MODES.include?(payment_mode)
      render json: { error: "Invalid payment mode" }, status: :unprocessable_entity
      return
    end

    if @invoice.update(payment_mode: payment_mode)
      render json: { success: true, payment_mode: payment_mode }, status: :ok
    else
      render json: { error: @invoice.errors.full_messages.join(", ") }, status: :unprocessable_entity
    end
  end

  private

  def set_invoice
    @invoice = current_vendor.invoices.find(params[:id] || params[:invoice_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to vendors_invoices_path, alert: "Invoice not found or you do not have access to it."
  end

  def set_publishable_key
    @publishable_key = ENV["STRIPE_PUBLISHABLE_KEY"]
  end
end
