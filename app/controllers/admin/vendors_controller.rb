class Admin::VendorsController < ApplicationController
  layout "admin"
  before_action :authenticate_admin!

  def index
    @vendors = Vendor.all
  end

  def show
    @vendor = Vendor.find(params[:id])
  end
end 