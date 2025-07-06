# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

Car.destroy_all

Car.create!([
  {
    brand: "Toyota",
    model: "Camry",
    year: 2022,
    color: "White",
    price: 55_000,
    status: "Available",
    category: "Sedan",
    main_image_url: "https://images.unsplash.com/photo-1503736334956-4c8f8e92946d?auto=format&fit=crop&w=800&q=80",
    description: "A reliable and comfortable sedan, perfect for city and highway driving.",
    transmission: "Automatic",
    fuel_type: "Petrol",
    seats: 5,
    mileage: 12000,
    engine_size: "2.5L",
    air_conditioning: true,
    gps: true,
    sunroof: false,
    bluetooth: true,
    usb_ports: 2,
    featured: true
  },
  {
    brand: "Honda",
    model: "Civic",
    year: 2021,
    color: "Blue",
    price: 48_000,
    status: "Available",
    category: "Sedan",
    main_image_url: "https://images.unsplash.com/photo-1461632830798-3adb3034e4c8?auto=format&fit=crop&w=800&q=80",
    description: "Sporty and efficient, the Civic is a favorite among young drivers.",
    transmission: "Manual",
    fuel_type: "Petrol",
    seats: 5,
    mileage: 8000,
    engine_size: "2.0L",
    air_conditioning: true,
    gps: false,
    sunroof: true,
    bluetooth: true,
    usb_ports: 2,
    featured: false
  },
  {
    brand: "BMW",
    model: "3 Series",
    year: 2023,
    color: "Black",
    price: 75_000,
    status: "Available",
    category: "Luxury",
    main_image_url: "https://images.unsplash.com/photo-1511918984145-48de785d4c4e?auto=format&fit=crop&w=800&q=80",
    description: "Luxury and performance combined. The 3 Series is a joy to drive.",
    transmission: "Automatic",
    fuel_type: "Diesel",
    seats: 5,
    mileage: 5000,
    engine_size: "3.0L",
    air_conditioning: true,
    gps: true,
    sunroof: true,
    bluetooth: true,
    usb_ports: 4,
    featured: true
  },
  {
    brand: "Ford",
    model: "Mustang",
    year: 2020,
    color: "Red",
    price: 68_000,
    status: "Available",
    category: "Sports",
    main_image_url: "https://images.unsplash.com/photo-1502877338535-766e1452684a?auto=format&fit=crop&w=800&q=80",
    description: "Iconic American muscle car. Feel the power of the Mustang!",
    transmission: "Manual",
    fuel_type: "Petrol",
    seats: 4,
    mileage: 15000,
    engine_size: "5.0L",
    air_conditioning: true,
    gps: false,
    sunroof: false,
    bluetooth: true,
    usb_ports: 2,
    featured: false
  },
  {
    brand: "Tesla",
    model: "Model 3",
    year: 2022,
    color: "Silver",
    price: 80_000,
    status: "Available",
    category: "Electric",
    main_image_url: "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?auto=format&fit=crop&w=800&q=80",
    description: "Experience the future with Tesla's all-electric Model 3.",
    transmission: "Automatic",
    fuel_type: "Electric",
    seats: 5,
    mileage: 3000,
    engine_size: "-",
    air_conditioning: true,
    gps: true,
    sunroof: true,
    bluetooth: true,
    usb_ports: 4,
    featured: true
  }
])

puts "Seeded #{Car.count} cars with images."
