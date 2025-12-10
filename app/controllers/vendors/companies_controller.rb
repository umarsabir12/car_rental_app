class Vendors::CompaniesController < ApplicationController
  before_action :authenticate_vendor!

  def index
    @companies = Vendor
      .left_joins(:cars)
      .where.not(company_name: [ nil, "" ])
      .select("company_name, COUNT(DISTINCT vendors.id) AS vendors_count, COUNT(cars.id) AS total_cars")
      .group("company_name")
      .order("company_name ASC")
  end
end
