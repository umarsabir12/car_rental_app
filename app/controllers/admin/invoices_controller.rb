class Admin::InvoicesController < ApplicationController
  layout "admin"

  before_action :authenticate_admin!
  before_action :set_vendor, only: [:index, :new, :create]
  before_action :set_invoice, only: [:show, :edit, :update, :destroy, :mark_as_paid]

  def index
    @invoices = @vendor.invoices.recent
  end

  def show
  end

  def new
    @invoice = @vendor.invoices.build
  end

  def create
    @invoice = @vendor.invoices.build(invoice_params)

    if @invoice.save!
      redirect_to admin_vendor_path(@vendor), notice: 'Invoice was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @invoice.update!(invoice_params.merge(payment_status: 'pending'))
      redirect_to admin_invoice_path(@invoice), notice: 'Invoice was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    vendor = @invoice.vendor  # Store vendor before destroying invoice
    @invoice.destroy
    redirect_to admin_vendor_invoices_path(vendor), notice: 'Invoice was successfully deleted.'
  end

  def mark_as_paid
    if @invoice.mark_as_paid!
      redirect_to admin_invoice_path(@invoice), notice: 'Invoice marked as paid.'
    else
      redirect_to admin_invoice_path(@invoice), alert: 'Could not update invoice.'
    end
  end

  private

  def set_vendor
    @vendor = Vendor.find(params[:vendor_id])
  end

  def set_invoice
    @invoice = Invoice.find(params[:id])
  end

  def invoice_params
    params.require(:invoice).permit(:due_date, :billing_type, :amount, :from_date, :to_date)
  end
end