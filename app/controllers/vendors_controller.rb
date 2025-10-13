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
    if @vendor.update(vendor_params.except(:trade_license))

      if params[:vendor][:trade_license].present?
        if @vendor.vendor_document.present?
          @vendor.vendor_document.trade_license.purge if @vendor.vendor_document.trade_license.attached?
          @vendor.vendor_document.trade_license.attach(params[:vendor][:trade_license])
          @vendor.vendor_document.document_status = :pending
          @vendor.vendor_document.save!
        else
          vendor_document = VendorDocument.new
          vendor_document.trade_license.attach(params[:vendor][:trade_license])
          vendor_document.document_status = :pending
          vendor_document.vendor = @vendor
          vendor_document.save!
        end
      end

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
      :company_logo, :address, :website, :description,
      :emirates_id, :emirates_id_expires_on, :trade_license, :whatsapp_number
    )
  end
end 
