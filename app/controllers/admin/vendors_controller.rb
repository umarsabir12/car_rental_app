class Admin::VendorsController < ApplicationController
  layout "admin"
  before_action :authenticate_admin!

  def index
    @vendors = Vendor.active.order(:company_name)
  end

  def show
    @vendor = Vendor.find(params[:id])
  end

  def destroy
    Rails.logger.info "=== DELETE REQUEST RECEIVED ==="
    Rails.logger.info "Params: #{params.inspect}"
    Rails.logger.info "Current admin: #{current_admin&.email}"
    
    @vendor = Vendor.find(params[:id])
    
    # Debug logging
    Rails.logger.info "Attempting to delete vendor: #{@vendor.id} - #{@vendor.company_name}"
    
    @vendor.soft_delete!

    Activity.log_activity(
      vendor: @vendor,
      subject: @vendor,
      action: 'vendor_deleted',
      description: "Vendor #{@vendor.company_name} was removed by admin",
      metadata: { 
        vendor_id: @vendor.id,
        vendor_name: @vendor.company_name,
        removed_by: current_admin.email
      }
    )
    
    Rails.logger.info "Vendor deleted successfully: #{@vendor.id}"
    redirect_to admin_vendors_path, notice: 'Vendor has been deleted successfully.'
  rescue => e
    Rails.logger.error "Error deleting vendor: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    redirect_to admin_vendor_path(@vendor), alert: "Error deleting vendor: #{e.message}"
  end

  def restore
    @vendor = Vendor.find(params[:id])
    @vendor.restore!
    
    # Log vendor restoration activity
    Activity.log_activity(
      vendor: @vendor,
      subject: @vendor,
      action: 'vendor_restored',
      description: "Vendor #{@vendor.company_name} was restored by admin",
      metadata: { 
        vendor_id: @vendor.id,
        vendor_name: @vendor.company_name,
        restored_by: current_admin.email
      }
    )
    
    redirect_to admin_vendors_path, notice: 'Vendor has been restored successfully.'
  end

  def download_report
    require 'csv'
    @vendors = Vendor.all
    csv_data = CSV.generate(headers: true) do |csv|
      csv << ["ID", "Name", "Email", "Phone", "Company Name", "Created At"]
      @vendors.each do |vendor|
        csv << [vendor.id, vendor.name, vendor.email, vendor.phone, vendor.company_name, vendor.created_at]
      end
    end
    send_data csv_data, filename: "vendors_report_#{Date.today}.csv"
  end

end 