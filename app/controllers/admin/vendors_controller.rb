class Admin::VendorsController < ApplicationController
  layout "admin"
  def index
    @vendors = [
      { id: 1, name: "Speedy Rentals", email: "contact@speedy.com" },
      { id: 2, name: "City Cars", email: "info@citycars.com" }
    ]
  end
end 