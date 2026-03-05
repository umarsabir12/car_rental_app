class Admin::InvoicesController < ApplicationController
  layout "admin"

  before_action :authenticate_admin!
  before_action :set_vendor, only: [ :index, :new, :create ]
  before_action :set_invoice, only: [ :show, :edit, :update, :destroy, :mark_as_paid ]

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

    respond_to do |format|
      if @invoice.save
        format.html { redirect_to admin_vendor_path(@vendor), notice: "Invoice was successfully created." }
      else
        flash.now[:alert] = "Error: #{@invoice.errors.full_messages.to_sentence}"
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("form-errors", partial: "shared/form_errors", locals: { object: @invoice }),
            turbo_stream.replace("flash-container", partial: "shared/flash_messages")
          ]
        end
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @invoice.update(invoice_params.merge(payment_status: "pending"))
        format.html { redirect_to admin_invoice_path(@invoice), notice: "Invoice was successfully updated." }
      else
        flash.now[:alert] = "Error: #{@invoice.errors.full_messages.to_sentence}"
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("form-errors", partial: "shared/form_errors", locals: { object: @invoice }),
            turbo_stream.replace("flash-container", partial: "shared/flash_messages")
          ]
        end
      end
    end
  end

  def destroy
    vendor = @invoice.vendor  # Store vendor before destroying invoice
    @invoice.destroy
    redirect_to admin_vendor_invoices_path(vendor), notice: "Invoice was successfully deleted."
  end

  def mark_as_paid
    respond_to do |format|
      if @invoice.mark_as_paid!
        format.html { redirect_to admin_invoice_path(@invoice), notice: "Invoice marked as paid." }
        format.turbo_stream { redirect_to admin_invoice_path(@invoice), notice: "Invoice marked as paid." }
      else
        format.html { redirect_to admin_invoice_path(@invoice), alert: "Could not update invoice." }
        format.turbo_stream { redirect_to admin_invoice_path(@invoice), alert: "Could not update invoice." }
      end
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
    params.require(:invoice).permit(
      :payment_status,
      :amount,
      invoice_items_attributes: [ :id, :description, :amount, :_destroy ]
    )
  end
end
