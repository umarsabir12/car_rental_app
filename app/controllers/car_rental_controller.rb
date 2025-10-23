class CarRentalController < ApplicationController
  def index
    # Set default dates
    @pick_date = Date.current.strftime('%Y-%m-%d')
    @drop_date = (Date.current + 3.days).strftime('%Y-%m-%d')
      
    # Locations data
    @locations = [
      { id: 'dubai', name: 'Dubai' },
      { id: 'abu-dhabi', name: 'Abu Dhabi' },
      { id: 'sharjah', name: 'Sharjah' },
      { id: 'ajman', name: 'Ajman' }
    ]

    @car_categories = AppConstants::CAR_CATEGORIES
    @car_brands = Car.distinct.pluck(:brand).compact.map { |b| [b.titleize, b] }
    @car_models = Car.distinct.pluck(:model).compact.map { |m| [m.titleize, m] }
      
    # Popular cars data
    @featured_cars = Car.order(bookings_count: :desc).limit(3).map do |car|
      {
        id: car.id,
        name: car.full_name,
        car_type: car.category,
        image_url: url_for(car.images.first),
        daily_price: car.daily_price,
        features: car.active_features
      }
    end
      
    # Brands data
    @brands = [
      { name: 'BMW', image_url: 'https://cdn.worldvectorlogo.com/logos/bmw.svg' },
      { name: 'Audi', image_url: 'https://cdn.worldvectorlogo.com/logos/audi-2009.svg' },
      { name: 'Mercedes', image_url: 'https://cdn.worldvectorlogo.com/logos/mercedes-benz-9.svg' },
      { name: 'Toyota', image_url: 'https://cdn.worldvectorlogo.com/logos/toyota-6.svg' }
    ]
      
    # Testimonials data
    @testimonials = [
      {
        author: 'Sarah Johnson',
        role: 'Business Traveler',
        quote: 'Excellent service and great cars. Made my business trip much more comfortable!'
      },
      {
        author: 'Mike Chen',
        role: 'Tourist',
        quote: 'Easy booking process and the car was in perfect condition. Highly recommended!'
      },
      {
        author: 'Emma Davis',
        role: 'Local Resident', 
        quote: 'Best car rental experience I have had. Will definitely use again.'
      }
    ]
      
    # Stats data
    @stats = [
      {value: '990+', label: 'BOOKINGS', icon: 'fa-calendar-check'},
      {value: '230+', label: 'CARS', icon: 'fa-car'},
      {value: '660+', label: 'HAPPY CUSTOMER', icon: 'fa-users'}
    ]
      
    # Company info
    @company = {
      name: 'WheelsOnRent',
      blurb: 'Your trusted partner for car rentals.'
    }
      
    # Contact info
    @contact = {
      phone: '+971506336408',
      email: 'booking@wheelsonrent.ae',
      address: 'Building A1, Dubai Digital Park, Dubai Silicon Oasis, Dubai'
    }
      
    # Set paths (adjust according to your routes)
    @cars_path = cars_path if respond_to?(:cars_path)

    @car_classes = [
      {name: 'Economy', image: 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?q=80&w=400&auto=format&fit=crop', daily_price: '$20/day'},
      {name: 'SUV', image: 'https://images.unsplash.com/photo-1583121274602-3e2820c69888?q=80&w=400&auto=format&fit=crop', daily_price: '$35/day'},
      {name: 'Convertible', image: 'https://images.unsplash.com/photo-1617788138017-80ad40651399?q=80&w=400&auto=format&fit=crop', daily_price: '$55/day'},
      {name: 'Sport', image: 'https://images.unsplash.com/photo-1544636331-e26879cd4d9b?q=80&w=400&auto=format&fit=crop', daily_price: '$75/day'},
      {name: 'Luxury', image: 'https://images.unsplash.com/photo-1563720223185-11003d516935?q=80&w=400&auto=format&fit=crop', daily_price: '$120/day'},
      {name: 'Electric', image: 'https://images.unsplash.com/photo-1560958089-b8a1929cea89?q=80&w=400&auto=format&fit=crop', daily_price: '$45/day'}
    ]

    # Use centralized brand mapping from Car model (slug, name, image under app/assets/images/brands)
    @brand_logos = Car.brand_logos

    @categories_to_display = [
      { name: 'SUVs', slug: 'SUV', description: 'From spacious 7-seaters to the latest 5-seater sports utility vehicles, rent an SUV for city drives or comfortable long hauls with ample seating and luggage space.' },
      { name: 'Luxury', slug: 'Luxury', description: 'Experience the pinnacle of automotive excellence with our premium luxury vehicles, featuring top-tier comfort, advanced technology, and prestigious brands.' },
      { name: 'Sports', slug: 'Sports', description: 'Feel the thrill of high-performance sports cars with powerful engines, sleek designs, and exceptional handling for an unforgettable driving experience in Dubai.' }
    ]

    @category_cars = ['SUV', 'Luxury', 'Sports'].flat_map do |category|
      Car.with_approved_mulkiya
         .where(category: category)
         .left_joins(:bookings)
         .select('cars.*, COUNT(bookings.id) as total_bookings')
         .group('cars.id')
         .order('total_bookings DESC, cars.created_at DESC')
         .limit(4)
    end
    
    @company_features = [
      {title: 'Luxury and Premium Cars', description: 'Enjoy Dubai in style with our luxury car rentals, including BMW 7 Series, Mercedes S-Class, and Audi A8. Perfect for business meetings, VIP events, or exploring Dubai’s skyline with elegance.'},
      {title: 'Sports and Exotic Cars', description: 'For those seeking adrenaline, Wheels on Rent offers sports and exotic cars such as Ferrari, Lamborghini, and Porsche. These rentals are popular among tourists looking for a memorable Dubai driving experience or special occasions.'},
      {title: 'Electric Car Rentals in Dubai', description: 'We provide eco-friendly options, including Tesla and other electric cars. Rent electric vehicles for sustainable and modern travel across Dubai and UAE, enjoying innovative technology and low environmental impact.'},
      {title: 'Car Rentals With Driver', description: 'For convenience and comfort, rent a car with a professional driver. Our trained chauffeurs can guide you through Dubai’s best routes, tourist destinations, or corporate travel needs, ensuring a stress-free journey.'},
      {title: 'Self-Drive Car Rentals', description: 'Experience freedom with self-drive rentals in Dubai. Explore the city and neighboring Emirates at your own pace, whether for tourism, shopping, or desert trips. All our cars are fully insured and maintained for safety.'},
      {title: 'Car Rentals for Tourism', description: 'Tourists can access curated services to explore Dubai’s attractions, including Burj Khalifa, Dubai Mall, Palm Jumeirah, and desert safaris. We provide detailed guidance for sightseeing and optimal vehicle choice for Dubai tourist travel.'},
      {title: 'Family and SUV Rentals', description: 'For family trips or group travel, Wheels on Rent offers spacious SUVs and family cars. These vehicles are perfect for road trips across UAE, desert excursions, or visiting Abu Dhabi, Sharjah, and Ras Al Khaimah.'},
      {title: 'Corporate Car Rentals in Dubai', description: 'Businesses can benefit from our corporate car rental services. We offer long-term rentals, airport transfers, and executive cars to ensure punctuality, comfort, and professionalism for employees and clients.'},
      {title: 'Airport Car Rentals in Dubai', description: 'Book a vehicle for Dubai International Airport pickups or departures. We provide fast delivery, flexible pick-up points, and a wide selection of cars, ensuring seamless travel for visitors and residents.'},
      {title: 'List Your Car and Earn', description: 'Wheels on Rent allows vehicle owners to list their cars for rent, offering a reliable income source. Our platform handles bookings, insurance, and customer verification, making it safe and convenient to monetize your vehicle.'},
      {title: 'Safety and Maintenance', description: 'All vehicles undergo regular inspections, sanitization, and maintenance. We provide road assistance, GPS tracking, and comprehensive insurance for peace of mind while driving across Dubai and UAE.'},
      {title: 'Flexible Rental Plans', description: 'Whether you need a car for a few hours, days, or months, our flexible rental plans in Dubai cater to short-term or long-term needs. Daily, weekly, and monthly packages ensure cost-effective solutions for every traveler.'},
      {title: 'Explore Dubai at Your Own Pace', description: 'Dubai is best explored at your own pace, and with Wheels on Rent, you can discover attractions like Dubai Marina, Jumeirah Beach, Al Fahidi Historical District, and Hatta mountains. Our vehicles provide a comfortable and efficient way to travel, combining convenience and freedom.'},
      {title: 'Affordable Pricing and Transparent Service', description: 'We maintain competitive and transparent pricing for all cars, including economy, luxury, sports, and electric vehicles. There are no hidden fees, and all taxes, insurance, and delivery charges are included in the rental agreement.'}
    ]

    @faqs = [
      {question: 'Can I rent a car in Dubai without a deposit?', answer: 'Yes, Wheels on Rent provides zero deposit options for select vehicles.'},
      {question: 'Do you provide cars with drivers for tourists?', answer: 'Yes, professional drivers are available for sightseeing, business trips, and airport transfers.'},
      {question: 'Can I rent electric or luxury cars?', answer: 'Absolutely. Our fleet includes luxury, sports, and electric vehicles.'},
      {question: 'How do I list my car for rent?', answer: 'Vehicle owners can submit their details on our website, and our team handles bookings, insurance, and payments. '},
      {question: 'Are your cars insured and maintained?', answer: 'All vehicles are fully insured, regularly serviced, and inspected before every rental.'},
      {question: 'Can I rent a car for a few hours or multiple days?', answer: 'Yes, we offer flexible rental plans for hourly, daily, weekly, or monthly rentals.'},
      {question: 'Do you provide airport car rentals in Dubai?', answer: 'Yes, we provide pickup and drop-off services at Dubai International Airport and other major airports.'},
    ]
  end
end