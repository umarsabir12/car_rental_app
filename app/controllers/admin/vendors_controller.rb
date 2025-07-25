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

end 