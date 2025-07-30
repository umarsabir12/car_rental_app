class VendorsController < ApplicationController
  before_action :authenticate_vendor!
  before_action :set_vendor

  def show
    # Show vendor profile information
  end

  def edit
    # Edit vendor profile form
  end

  def update
    if @vendor.update(vendor_params)
      redirect_to vendor_path(@vendor), notice: 'Profile was successfully updated.'
    else
      flash.now[:alert] = 'Failed to update profile. Please check the errors below.'
      render :edit
    end
  end

  private

  def set_vendor
    @vendor = current_vendor
  end

  def vendor_params
    params.require(:vendor).permit(
      :first_name, :last_name, :email, :phone, :company_name,
      :company_logo, :address, :website, :description
    )
  end
end 
