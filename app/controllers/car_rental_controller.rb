class CarRentalController < ApplicationController

    def index
        @featured_cars = [
        {
        id: 1,
        name: "Toyota Camry",
        car_type: "Sedan",
        price: 45,
        image_url: "https://images.unsplash.com/photo-1503736334956-4c8f8e92946d?auto=format&fit=crop&w=800&q=80",
        features: ["5 Seats", "Automatic", "Air Conditioning"]
        },
        {
        id: 2,
        name: "Honda CR-V",
        car_type: "SUV",
        price: 65,
        image_url: "https://images.unsplash.com/photo-1552519507-da3b142c6e3d?auto=format&fit=crop&w=800&q=80",
        features: ["7 Seats", "AWD", "GPS Navigation"]
        },
        {
        id: 3,
        name: "BMW 3 Series",
        car_type: "Luxury",
        price: 89,
        image_url: "https://images.unsplash.com/photo-1555215695-3004980ad54e?auto=format&fit=crop&w=800&q=80",
        features: ["5 Seats", "Premium Interior", "Sport Package"]
        }]
    end

end