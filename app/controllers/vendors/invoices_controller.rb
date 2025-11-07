class Vendors::InvoicesController < ApplicationController
  before_action :authenticate_vendor!
  before_action :set_invoice, only: [:show]

  def index
    @invoices = current_vendor.invoices.includes(:vendor).order(created_at: :desc)
  end

  def show
  end

  def pay
    # TODO: Implement Stripe payment processing here
    # For now, just redirect with a notice
    
    if @invoice.payment_status == 'paid'
      redirect_to vendors_invoice_path(@invoice), alert: 'This invoice has already been paid.'
      return
    end

    # Placeholder for Stripe payment processing
    # When Stripe is configured, add:
    # 1. Create Stripe PaymentIntent
    # 2. Confirm payment
    # 3. Update invoice status
    # 4. Send receipt email
    
    flash[:notice] = 'Payment processing will be implemented once Stripe is configured.'
    redirect_to vendors_invoice_path(@invoice)
  end

  private

  def set_invoice
    @invoice = current_vendor.invoices.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to vendors_invoices_path, alert: 'Invoice not found or you do not have access to it.'
  end
end 
