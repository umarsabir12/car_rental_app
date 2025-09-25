class CompaniesController < ApplicationController
  def index
    # Prefer join-based aggregation to avoid relying on a cars_count column
    @companies = Vendor
      .left_joins(:cars)
      .where.not(company_name: [nil, ''])
      .select(
        'company_name, COUNT(DISTINCT vendors.id) AS vendors_count, COUNT(cars.id) AS total_cars'
      )
      .group('company_name')
      .order('company_name ASC')
  end
end


