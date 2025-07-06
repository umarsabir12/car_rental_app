class Admin::CustomersController < ApplicationController
  layout "admin"
  def index
    @customers = [
      { name: "Liam Johnson", car_type: "Honda Brio", car_number: "010 MOR", status: "On Going", avatar_url: "https://i.pravatar.cc/40?img=1" },
      { name: "Noah Anderson", car_type: "Pajero Sport", car_number: "696 TON", status: "Finished", avatar_url: "https://i.pravatar.cc/40?img=2" },
      { name: "Ethan Smith", car_type: "Agya", car_number: "665 KIT", status: "Finished", avatar_url: "https://i.pravatar.cc/40?img=3" },
      { name: "Mason Davis", car_type: nil, car_number: nil, status: "Canceled", avatar_url: "https://i.pravatar.cc/40?img=4" }
    ]
  end
end 