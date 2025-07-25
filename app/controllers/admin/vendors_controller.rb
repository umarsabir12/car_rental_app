class Admin::VendorsController < ApplicationController
  layout "admin"
  before_action :authenticate_admin!

  def index
    @vendors = Vendor.all
  end

  def show
    @vendor = Vendor.find(params[:id])
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

  def new_invite
    @vendor = Vendor.new
  end

  def create_invite
    @vendor = Vendor.new(vendor_invite_params)
    if @vendor.save
      VendorMailer.invite_email(@vendor, params[:vendor][:password]).deliver_later
      redirect_to admin_vendors_path, notice: 'Vendor invited and email sent.'
    else
      flash.now[:alert] = @vendor.errors.full_messages.to_sentence
      render :new_invite, status: :unprocessable_entity
    end
  end

  private

  def vendor_invite_params
    params.require(:vendor).permit(:email, :first_name, :last_name, :password, :company_name)
  end
end 