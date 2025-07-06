class Admin::BookingsController < ApplicationController
  layout "admin"
  def index
    @bookings = [
      { id: 1, customer: "Alice Smith", car: "Toyota Camry", date: "2024-06-01" },
      { id: 2, customer: "Bob Johnson", car: "Honda Civic", date: "2024-06-02" }
    ]
  end
end 