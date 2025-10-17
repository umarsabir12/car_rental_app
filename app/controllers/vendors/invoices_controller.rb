class Vendors::InvoicesController < ApplicationController
  before_action :authenticate_vendor!
  before_action :set_invoice, only: [:show]

  def index
    @invoices = current_vendor.invoices.includes(:vendor).order(created_at: :desc)
  end

  def show
  end

  private

  def set_invoice
    @invoice = current_vendor.invoices.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to vendors_invoices_path, alert: 'Invoice not found or you do not have access to it.'
  end
end 
