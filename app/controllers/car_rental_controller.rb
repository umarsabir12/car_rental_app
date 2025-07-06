class CarRentalController < ApplicationController

    def index
        @featured_cars = [
        {
        id: 1,
        name: "Toyota Camry",
        type: "Sedan",
        price: 45,
        image: "/placeholder.svg",
        features: ["5 Seats", "Automatic", "Air Conditioning"]
        },
        {
        id: 2,
        name: "Honda CR-V",
        type: "SUV",
        price: 65,
        image: "/placeholder.svg",
        features: ["7 Seats", "AWD", "GPS Navigation"]
        },
        {
        id: 3,
        name: "BMW 3 Series",
        type: "Luxury",
        price: 89,
        image: "/placeholder.svg",
        features: ["5 Seats", "Premium Interior", "Sport Package"]
        }]
    end

end