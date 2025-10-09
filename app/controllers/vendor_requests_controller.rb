class VendorRequestsController < ApplicationController

  def new
    @vendor_request = VendorRequest.new
  end
  
  def create
    @vendor_request = VendorRequest.new(vendor_request_params)
    
    if @vendor_request.save
      VendorRequest.request_email(@vendor_request.id).deliver_now
      redirect_to root_path, notice: 'Your request has been submitted successfully! We will review it and get back to you soon.'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  private
  
  def vendor_request_params
    params.require(:vendor_request).permit(:first_name, :last_name, :email, :description)
  end
end