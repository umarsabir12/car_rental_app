class Admin::VendorRequestsController < ApplicationController
  layout "admin"
  before_action :authenticate_admin!
  before_action :set_vendor_request, only: [:approve, :reject]
  
  def index
    @vendor_requests = VendorRequest.order(created_at: :desc)
    
    # Optional: Filter by status
    if params[:status].present?
      @vendor_requests = @vendor_requests.where(status: params[:status])
    end
  end

  def approve
    if @vendor_request.approve!
      @invited_vendor = InvitedVendor.new(first_name: @vendor_request.first_name, last_name: @vendor_request.last_name, email: @vendor_request.email)
      if @invited_vendor.save
        redirect_to admin_vendor_requests_path, notice: 'Vendor request approved & invited successfully.'
      end
      
    else
      redirect_to admin_vendor_requests_path, alert: 'Failed to approve vendor request.'
    end
  end

  def reject
    if @vendor_request.reject!
      # Optional: Send rejection email
      VendorMailer.reject_email(vendor_email: @vendor_request.email, first_name: @vendor_request.first_name, last_name: @vendor_request.last_name).deliver_now
      @vendor_request.destroy
      redirect_to admin_vendor_requests_path, notice: 'Vendor request rejected.'
    else
      redirect_to admin_vendor_requests_path, alert: 'Failed to reject vendor request.'
    end
  end

  private
  
  def set_vendor_request
    @vendor_request = VendorRequest.find(params[:id])
  end
end