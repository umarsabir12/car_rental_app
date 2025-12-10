class Vendors::DashboardController < ApplicationController
  before_action :authenticate_vendor!

  def index
    # Add dashboard stats and data here
  end
end
