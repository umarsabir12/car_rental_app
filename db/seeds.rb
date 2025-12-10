# Clear existing data in FK-safe order
puts "Clearing existing data..."
require 'securerandom'

# Clear hard dependencies first
Transaction.destroy_all rescue nil
Booking.destroy_all rescue nil
Document.destroy_all rescue nil

# Then parents
Car.destroy_all rescue nil
Vendor.destroy_all rescue nil
Admin.destroy_all rescue nil
User.destroy_all rescue nil

# Optional ancillary tables
InvitedVendor.destroy_all rescue nil

# Reset auto-increment counters to avoid ID conflicts
ActiveRecord::Base.connection.execute("DELETE FROM sqlite_sequence") if ActiveRecord::Base.connection.adapter_name.downcase.include?('sqlite')

puts "All data cleared successfully"

# Admins
puts "Creating admins..."
super_admin = Admin.create!(
  email: "superadmin@example.com",
  password: "password123",
  password_confirmation: "password123",
  first_name: "Super",
  last_name: "Admin",
  role_type: "super_admin"
)

admin = Admin.create!(
  email: "admin@example.com",
  password: "password123",
  password_confirmation: "password123",
  first_name: "Site",
  last_name: "Admin",
  role_type: "admin"
)

puts "Created #{Admin.count} admins"

# Create 2 users
puts "Creating users..."
user1 = User.create!(
  email: "john@example.com",
  password: "password123",
  password_confirmation: "password123",
  first_name: "John",
  last_name: "Doe",
  phone: "+1-555-0123",
  home_address: "123 Main St, New York, NY 10001",
  nationality: "resident",
  terms_accepted: true
)

user2 = User.create!(
  email: "jane@example.com",
  password: "password123",
  password_confirmation: "password123",
  first_name: "Jane",
  last_name: "Smith",
  phone: "+1-555-0456",
  home_address: "456 Oak Ave, Los Angeles, CA 90210",
  nationality: "tourist",
  terms_accepted: true
)

puts "Created #{User.count} users"

# === VENDORS === (Single section, removed duplicate)
puts "Creating vendors..."
vendor1 = Vendor.create!(
  first_name: "Speedy",
  last_name: "Rentals",
  email: "speedy@rentals.com",
  password: "password123",
  phone: "+1-555-123-4567",
  company_name: "Speedy Rentals Inc.",
  company_logo: "https://randomuser.me/api/portraits/men/32.jpg",
  address: "123 Fast Lane, New York, NY 10001",
  website: "https://speedyrentals.com",
  description: "Fast and reliable car rentals for all your needs.",
  emirates_id: "784198765432109",
  emirates_id_expires_on: Date.current + 1.year
)

vendor2 = Vendor.create!(
  first_name: "City",
  last_name: "Cars",
  email: "info@citycars.com",
  password: "password123",
  phone: "+1-555-987-6543",
  company_name: "City Cars LLC",
  company_logo: "https://randomuser.me/api/portraits/women/44.jpg",
  address: "456 Urban Ave, Los Angeles, CA 90210",
  website: "https://citycars.com",
  description: "Your trusted partner for city driving.",
  emirates_id: "784123456789012",
  emirates_id_expires_on: Date.current + 1.year
)

vendor3 = Vendor.create!(
  first_name: "Luxury",
  last_name: "Wheels",
  email: "contact@luxurywheels.com",
  password: "password123",
  phone: "+1-555-222-3333",
  company_name: "Luxury Wheels Group",
  company_logo: "https://randomuser.me/api/portraits/men/55.jpg",
  address: "789 Elite Rd, Miami, FL 33101",
  website: "https://luxurywheels.com",
  description: "Premium and luxury vehicles for special occasions.",
  emirates_id: "784109876543210",
  emirates_id_expires_on: Date.current + 6.months
)

vendor4 = Vendor.create!(
  first_name: "Eco",
  last_name: "Drive",
  email: "hello@ecodrive.com",
  password: "password123",
  phone: "+1-555-444-5555",
  company_name: "Eco Drive Solutions",
  company_logo: "https://randomuser.me/api/portraits/women/65.jpg",
  address: "321 Green St, San Francisco, CA 94105",
  website: "https://ecodrive.com",
  description: "Eco-friendly and hybrid car rentals.",
  emirates_id: "784100000000001",
  emirates_id_expires_on: Date.current + 2.years
)

puts "Created #{Vendor.count} vendors"

# Create 20 cars with valid images
puts "Creating cars..."

# Disable Stripe callbacks during seeding to avoid external API calls
Car.skip_callback(:create, :after, :create_stripe_product) rescue nil
Car.skip_callback(:create, :after, :create_stripe_price) rescue nil

cars_data = [
  {
    brand: "Toyota",
    model: "Camry",
    year: 2022,
    color: "White",
    price: 55,
    status: "available",
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
    featured: true,
    vendor: vendor1
  },
  {
    brand: "Honda",
    model: "Civic",
    year: 2021,
    color: "Blue",
    price: 48,
    status: "available",
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
    featured: false,
    vendor: vendor1
  },
  {
    brand: "BMW",
    model: "3 Series",
    year: 2023,
    color: "Black",
    price: 75,
    status: "available",
    category: "Luxury",
    main_image_url: "https://images.unsplash.com/photo-1555215695-3004980ad54e?auto=format&fit=crop&w=800&q=80",
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
    featured: true,
    vendor: vendor1
  },
  {
    brand: "Ford",
    model: "Mustang",
    year: 2020,
    color: "Red",
    price: 68,
    status: "available",
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
    featured: false,
    vendor: vendor2
  },
  {
    brand: "Tesla",
    model: "Model 3",
    year: 2022,
    color: "Silver",
    price: 80,
    status: "available",
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
    featured: true,
    vendor: vendor2
  },
  {
    brand: "Mercedes-Benz",
    model: "C-Class",
    year: 2023,
    color: "Silver",
    price: 85,
    status: "available",
    category: "Luxury",
    main_image_url: "https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?auto=format&fit=crop&w=800&q=80",
    description: "Elegant luxury sedan with premium features and comfort.",
    transmission: "Automatic",
    fuel_type: "Petrol",
    seats: 5,
    mileage: 4000,
    engine_size: "2.0L",
    air_conditioning: true,
    gps: true,
    sunroof: true,
    bluetooth: true,
    usb_ports: 4,
    featured: false,
    vendor: vendor2
  },
  {
    brand: "Audi",
    model: "A4",
    year: 2022,
    color: "Gray",
    price: 72,
    status: "available",
    category: "Luxury",
    main_image_url: "https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?auto=format&fit=crop&w=800&q=80",
    description: "Sophisticated German engineering with quattro all-wheel drive.",
    transmission: "Automatic",
    fuel_type: "Petrol",
    seats: 5,
    mileage: 9000,
    engine_size: "2.0L",
    air_conditioning: true,
    gps: true,
    sunroof: false,
    bluetooth: true,
    usb_ports: 3,
    featured: false,
    vendor: vendor3
  },
  {
    brand: "Hyundai",
    model: "Tucson",
    year: 2023,
    color: "Blue",
    price: 45,
    status: "available",
    category: "SUV",
    main_image_url: "https://images.unsplash.com/photo-1552519507-da3b142c6e3d?auto=format&fit=crop&w=800&q=80",
    description: "Modern SUV with great fuel efficiency and technology.",
    transmission: "Automatic",
    fuel_type: "Hybrid",
    seats: 5,
    mileage: 6000,
    engine_size: "1.6L",
    air_conditioning: true,
    gps: true,
    sunroof: true,
    bluetooth: true,
    usb_ports: 3,
    featured: false,
    vendor: vendor3
  },
  {
    brand: "Kia",
    model: "Sportage",
    year: 2022,
    color: "White",
    price: 42,
    status: "available",
    category: "SUV",
    main_image_url: "https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?auto=format&fit=crop&w=800&q=80",
    description: "Stylish SUV with excellent warranty and features.",
    transmission: "Automatic",
    fuel_type: "Petrol",
    seats: 5,
    mileage: 11000,
    engine_size: "2.0L",
    air_conditioning: true,
    gps: true,
    sunroof: false,
    bluetooth: true,
    usb_ports: 2,
    featured: false,
    vendor: vendor3
  },
  {
    brand: "Volkswagen",
    model: "Golf",
    year: 2021,
    color: "Red",
    price: 38,
    status: "available",
    category: "Compact",
    main_image_url: "https://images.unsplash.com/photo-1549924231-f129b911e442?auto=format&fit=crop&w=800&q=80",
    description: "Fun to drive hatchback with German engineering.",
    transmission: "Manual",
    fuel_type: "Petrol",
    seats: 5,
    mileage: 14000,
    engine_size: "1.5L",
    air_conditioning: true,
    gps: false,
    sunroof: true,
    bluetooth: true,
    usb_ports: 2,
    featured: false,
    vendor: vendor4
  },
  {
    brand: "Nissan",
    model: "Altima",
    year: 2022,
    color: "Black",
    price: 50,
    status: "available",
    category: "Sedan",
    main_image_url: "https://images.unsplash.com/photo-1617470706004-e6ed057f782c?auto=format&fit=crop&w=800&q=80",
    description: "Comfortable sedan with excellent fuel economy.",
    transmission: "Automatic",
    fuel_type: "Petrol",
    seats: 5,
    mileage: 10000,
    engine_size: "2.5L",
    air_conditioning: true,
    gps: true,
    sunroof: false,
    bluetooth: true,
    usb_ports: 2,
    featured: false,
    vendor: vendor4
  },
  {
    brand: "Chevrolet",
    model: "Camaro",
    year: 2021,
    color: "Yellow",
    price: 70,
    status: "available",
    category: "Sports",
    main_image_url: "https://images.unsplash.com/photo-1582639510494-c80b5de9f148?auto=format&fit=crop&w=800&q=80",
    description: "American muscle car with aggressive styling and performance.",
    transmission: "Manual",
    fuel_type: "Petrol",
    seats: 4,
    mileage: 12000,
    engine_size: "3.6L",
    air_conditioning: true,
    gps: false,
    sunroof: true,
    bluetooth: true,
    usb_ports: 2,
    featured: false,
    vendor: vendor4
  },
  {
    brand: "Jeep",
    model: "Wrangler",
    year: 2023,
    color: "Green",
    price: 65,
    status: "available",
    category: "SUV",
    main_image_url: "https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?auto=format&fit=crop&w=800&q=80",
    description: "Iconic off-road vehicle perfect for adventure.",
    transmission: "Manual",
    fuel_type: "Petrol",
    seats: 5,
    mileage: 7000,
    engine_size: "3.6L",
    air_conditioning: true,
    gps: true,
    sunroof: true,
    bluetooth: true,
    usb_ports: 2,
    featured: false,
    vendor: vendor1
  },
  {
    brand: "Lexus",
    model: "RX",
    year: 2022,
    color: "Silver",
    price: 90,
    status: "available",
    category: "Luxury",
    main_image_url: "https://images.unsplash.com/photo-1617470706004-e6ed057f782c?auto=format&fit=crop&w=800&q=80",
    description: "Luxury SUV with exceptional reliability and comfort.",
    transmission: "Automatic",
    fuel_type: "Hybrid",
    seats: 5,
    mileage: 8000,
    engine_size: "2.5L",
    air_conditioning: true,
    gps: true,
    sunroof: true,
    bluetooth: true,
    usb_ports: 4,
    featured: true,
    vendor: vendor2
  },
  {
    brand: "Subaru",
    model: "Outback",
    year: 2023,
    color: "Blue",
    price: 52,
    status: "available",
    category: "SUV",
    main_image_url: "https://images.unsplash.com/photo-1552519507-da3b142c6e3d?auto=format&fit=crop&w=800&q=80",
    description: "All-wheel drive wagon perfect for any weather.",
    transmission: "Automatic",
    fuel_type: "Petrol",
    seats: 5,
    mileage: 5000,
    engine_size: "2.5L",
    air_conditioning: true,
    gps: true,
    sunroof: false,
    bluetooth: true,
    usb_ports: 3,
    featured: false,
    vendor: vendor3
  },
  {
    brand: "Mazda",
    model: "CX-5",
    year: 2022,
    color: "Red",
    price: 48,
    status: "available",
    category: "SUV",
    main_image_url: "https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?auto=format&fit=crop&w=800&q=80",
    description: "Stylish SUV with excellent driving dynamics.",
    transmission: "Automatic",
    fuel_type: "Petrol",
    seats: 5,
    mileage: 13000,
    engine_size: "2.5L",
    air_conditioning: true,
    gps: true,
    sunroof: true,
    bluetooth: true,
    usb_ports: 2,
    featured: false,
    vendor: vendor4
  },
  {
    brand: "Volvo",
    model: "XC60",
    year: 2023,
    color: "White",
    price: 78,
    status: "available",
    category: "Luxury",
    main_image_url: "https://images.unsplash.com/photo-1617470706004-e6ed057f782c?auto=format&fit=crop&w=800&q=80",
    description: "Safety-focused luxury SUV with Scandinavian design.",
    transmission: "Automatic",
    fuel_type: "Hybrid",
    seats: 5,
    mileage: 4000,
    engine_size: "2.0L",
    air_conditioning: true,
    gps: true,
    sunroof: true,
    bluetooth: true,
    usb_ports: 4,
    featured: false,
    vendor: vendor1
  },
  {
    brand: "Land Rover",
    model: "Range Rover Sport",
    year: 2022,
    color: "Black",
    price: 120,
    status: "available",
    category: "Luxury",
    main_image_url: "https://images.unsplash.com/photo-1552519507-da3b142c6e3d?auto=format&fit=crop&w=800&q=80",
    description: "Ultimate luxury SUV with off-road capability.",
    transmission: "Automatic",
    fuel_type: "Petrol",
    seats: 5,
    mileage: 9000,
    engine_size: "3.0L",
    air_conditioning: true,
    gps: true,
    sunroof: true,
    bluetooth: true,
    usb_ports: 4,
    featured: true,
    vendor: vendor2
  },
  {
    brand: "Porsche",
    model: "911",
    year: 2021,
    color: "Red",
    price: 150,
    status: "available",
    category: "Sports",
    main_image_url: "https://images.unsplash.com/photo-1502877338535-766e1452684a?auto=format&fit=crop&w=800&q=80",
    description: "Iconic sports car with unmatched performance.",
    transmission: "Manual",
    fuel_type: "Petrol",
    seats: 2,
    mileage: 8000,
    engine_size: "3.0L",
    air_conditioning: true,
    gps: true,
    sunroof: false,
    bluetooth: true,
    usb_ports: 2,
    featured: true,
    vendor: vendor3
  },
  {
    brand: "Jaguar",
    model: "F-Type",
    year: 2022,
    color: "British Racing Green",
    price: 110,
    status: "available",
    category: "Sports",
    main_image_url: "https://images.unsplash.com/photo-1582639510494-c80b5de9f148?auto=format&fit=crop&w=800&q=80",
    description: "British sports car with elegant design and performance.",
    transmission: "Automatic",
    fuel_type: "Petrol",
    seats: 2,
    mileage: 6000,
    engine_size: "3.0L",
    air_conditioning: true,
    gps: true,
    sunroof: true,
    bluetooth: true,
    usb_ports: 2,
    featured: false,
    vendor: vendor4
  }
]

cars_data.each do |car_data|
  # Map legacy attributes to current schema and drop unknown keys
  mapped_data = car_data.dup
  mapped_data[:daily_price] = mapped_data.delete(:price) if mapped_data.key?(:price)
  mapped_data.delete(:usb_ports)
  mapped_data[:weekly_price] = (mapped_data[:daily_price].to_f * 6.5).round(2)
  mapped_data[:monthly_price] = (mapped_data[:daily_price].to_f * 26).round(2)
  mapped_data[:daily_milleage] = 250
  mapped_data[:weekly_milleage] = 1200
  mapped_data[:monthly_milleage] = 4000

  # Bypass validations like mulkiya presence during seeding
  car = Car.new(mapped_data)
  car.save!(validate: false)
  # Ensure each car has a CarDocument with a mix of statuses (bypass file validations)
  next unless car.persisted?
  status = [ :pending, :approved, :rejected ][rand(0..2)]
  car_doc = CarDocument.new(car: car, document_status: status)
  car_doc.save(validate: false)
end

# Re-enable Stripe callbacks after seeding
Car.set_callback(:create, :after, :create_stripe_product) rescue nil
Car.set_callback(:create, :after, :create_stripe_price) rescue nil

puts "Created #{Car.count} cars"

# Force one vendor to have an expired Emirates ID to exercise the scope, bypassing validations
vendor2.update_columns(emirates_id_expires_on: Date.current - 1.month)

# Create some sample bookings with required fields and UNIQUE Stripe IDs
puts "Creating sample bookings..."
cars = Car.all.to_a
car1 = cars.first
car2 = cars.second
car3 = cars.third

def price_for(car, period)
  case period
  when 'daily' then car.daily_price
  when 'weekly' then car.weekly_price
  when 'monthly' then car.monthly_price
  else car.daily_price
  end
end

# Generate unique Stripe IDs with timestamps to prevent collisions
timestamp = Time.current.to_i
session_id_1 = "cs_test_#{timestamp}_#{SecureRandom.hex(8)}"
payment_intent_id_1 = "pi_test_#{timestamp}_#{SecureRandom.hex(8)}"
session_id_2 = "cs_test_#{timestamp + 1}_#{SecureRandom.hex(8)}"
payment_intent_id_2 = "pi_test_#{timestamp + 1}_#{SecureRandom.hex(8)}"
session_id_3 = "cs_test_#{timestamp + 2}_#{SecureRandom.hex(8)}"
payment_intent_id_3 = "pi_test_#{timestamp + 2}_#{SecureRandom.hex(8)}"

b1 = Booking.create!(
  user: user1,
  car: car1,
  start_date: Date.current + 5.days,
  end_date: Date.current + 8.days,
  selected_period: 'daily',
  selected_price: price_for(car1, 'daily'),
  selected_mileage_limit: car1.daily_milleage,
  payment_mode: :Online,
  stripe_session_id: session_id_1,
  stripe_payment_intent_id: payment_intent_id_1,
  payment_processed: true
)

b2 = Booking.create!(
  user: user2,
  car: car2,
  start_date: Date.current + 10.days,
  end_date: Date.current + 17.days,
  selected_period: 'weekly',
  selected_price: price_for(car2, 'weekly'),
  selected_mileage_limit: car2.weekly_milleage,
  payment_mode: :Cash,
  stripe_session_id: session_id_2,
  stripe_payment_intent_id: payment_intent_id_2,
  payment_processed: false
)

b3 = Booking.create!(
  user: user1,
  car: car3,
  start_date: Date.current + 20.days,
  end_date: Date.current + 50.days,
  selected_period: 'monthly',
  selected_price: price_for(car3, 'monthly'),
  selected_mileage_limit: car3.monthly_milleage,
  payment_mode: :Online,
  stripe_session_id: session_id_3,
  stripe_payment_intent_id: payment_intent_id_3,
  payment_processed: true
)

puts "Created #{Booking.count} bookings"

# Transactions to cover payment states
puts "Creating transactions..."
Transaction.create!(
  booking: b1,
  stripe_session_id: b1.stripe_session_id,
  stripe_payment_intent_id: b1.stripe_payment_intent_id,
  amount: b1.selected_price,
  status: 'completed',
  transaction_type: 'payment',
  processed_at: Time.current
)

Transaction.create!(
  booking: b2,
  stripe_session_id: b2.stripe_session_id,
  stripe_payment_intent_id: b2.stripe_payment_intent_id,
  amount: b2.selected_price,
  status: 'pending',
  transaction_type: 'payment'
)

Transaction.create!(
  booking: b3,
  stripe_session_id: b3.stripe_session_id,
  stripe_payment_intent_id: b3.stripe_payment_intent_id,
  amount: b3.selected_price,
  status: 'failed',
  transaction_type: 'payment',
  processed_at: Time.current
)

# A refund record for coverage - using unique IDs for refund
refund_session_id = "cs_refund_#{timestamp}_#{SecureRandom.hex(8)}"
refund_payment_intent_id = "pi_refund_#{timestamp}_#{SecureRandom.hex(8)}"

Transaction.create!(
  booking: b1,
  stripe_session_id: refund_session_id,
  stripe_payment_intent_id: refund_payment_intent_id,
  amount: (b1.selected_price.to_f / 2.0),
  status: 'completed',
  transaction_type: 'refund',
  refund_reason: 'Customer request',
  processed_at: Time.current
)

puts "Created #{Transaction.count} transactions"

# Document status scenarios to exercise features
puts "Updating document statuses to exercise flows..."
# For user1: mix of statuses
user1.documents.where(doc_name: Document::RESIDENT).limit(1).update_all(status: 'approved')
user1.documents.where(doc_name: Document::RESIDENT).offset(1).limit(1).update_all(status: 'pending')
user1.documents.where(doc_name: Document::RESIDENT).offset(2).update_all(status: 'not uploaded')

# For user2: approve all to trigger booking auto-confirm via callback
user2.documents.update_all(status: 'approved')

# Invited vendors to cover invitation flows
puts "Creating invited vendors..."

# Skip email sending callbacks during seeding
InvitedVendor.skip_callback(:create, :after, :send_invite_email) rescue nil
InvitedVendor.skip_callback(:after_create, :send_invite_email) rescue nil

InvitedVendor.create!([
  {
    email: 'newpartner@rents.com',
    first_name: 'New',
    last_name: 'Partner',
    invite_token: SecureRandom.hex(16), # Use longer token to avoid collisions
    invite_sent: true,
    status: 'pending'
  },
  {
    email: 'expired@vendor.com',
    first_name: 'Old',
    last_name: 'Invite',
    invite_token: SecureRandom.hex(16), # Use longer token to avoid collisions
    invite_sent: true,
    status: 'pending'
  }
])

# Re-enable the callback after seeding
InvitedVendor.set_callback(:create, :after, :send_invite_email) rescue nil
InvitedVendor.set_callback(:after_create, :send_invite_email) rescue nil

puts "Created #{InvitedVendor.count} invited vendors"

puts "\n=== SEEDING COMPLETE ==="
puts "Users: #{User.count}"
puts "Cars: #{Car.count}"
puts "Bookings: #{Booking.count}"
puts "Vendors: #{Vendor.count}"
puts "Admins: #{Admin.count}"
puts "Transactions: #{Transaction.count}"
puts "Invited Vendors: #{InvitedVendor.count}"
puts "\nSample user credentials:"
puts "Email: john@example.com, Password: password123"
puts "Email: jane@example.com, Password: password123"
puts "Vendor: speedy@rentals.com, Password: password123"
puts "Vendor: info@citycars.com, Password: password123"
puts "Admin: superadmin@example.com, Password: password123"
puts "Admin: admin@example.com, Password: password123"
