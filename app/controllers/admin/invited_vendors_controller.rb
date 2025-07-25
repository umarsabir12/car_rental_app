class Admin::InvitedVendorsController < ApplicationController
  layout "admin"
  before_action :authenticate_admin!

  def index
    @invited_vendors = InvitedVendor.all
  end

  def new
    @invited_vendor = InvitedVendor.new
  end

  def create
    @invited_vendor = InvitedVendor.new(invited_vendor_params)
    if @invited_vendor.save
      redirect_to admin_vendors_path, notice: 'Invited vendor created successfully'
    end
  end

  private

  def invited_vendor_params
    params.require(:invited_vendor).permit(:email, :first_name, :last_name)
  end
end