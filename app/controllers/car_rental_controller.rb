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
      
    # Featured cars data
    @featured_cars = [
      {
        id: 1,
        name: 'Cadillac Escalade Limited',
        car_type: 'SUV',
        image_url: 'https://images.unsplash.com/photo-1549923746-c502d488b3ea?q=80&w=800&auto=format&fit=crop',
        daily_price: 89,
        features: ['GPS Navigation', 'Bluetooth', 'Air Conditioning']
      },
      {
        id: 2,
        name: 'BMW X5 Limited',
        car_type: 'SUV', 
        image_url: 'https://images.unsplash.com/photo-1555215695-3004980ad54e?q=80&w=800&auto=format&fit=crop',
        daily_price: 79,
        features: ['Premium Interior', 'All-wheel Drive', 'Safety Features']
      },
      {
        id: 3,
        name: 'Audi Q5 Sedan',
        car_type: 'Sedan',
        image_url: 'https://images.unsplash.com/photo-1603584173870-7f23fdae1b7a?q=80&w=800&auto=format&fit=crop',
        daily_price: 69,
        features: ['Luxury Seats', 'Advanced Tech', 'Premium Sound']
      }
    ]
      
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
      {value: '990+', label: 'CARS RENTOUTS', icon: 'fa-car'},
      {value: '230+', label: 'CARS SOLUTIONS', icon: 'fa-wrench'},
      {value: '660+', label: 'HAPPY CUSTOMER', icon: 'fa-users'}
    ]
      
    # Company info
    @company = {
      name: 'WheelsOnRent',
      blurb: 'Your trusted partner for car rentals.'
    }
      
    # Contact info
    @contact = {
      phone: '1-800-WheelsOnRent',
      email: 'support@wheelsonrent.com',
      address: '123 Rental Street, Dubai, UAE'
    }
      
    # Set paths (adjust according to your routes)
    @cars_path = cars_path if respond_to?(:cars_path)

    @car_classes = [
      {name: 'Economy', image: 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?q=80&w=400&auto=format&fit=crop', daily_price: '$20/day'},
      {name: 'Standard', image: 'https://images.unsplash.com/photo-1583121274602-3e2820c69888?q=80&w=400&auto=format&fit=crop', daily_price: '$35/day'},
      {name: 'Convertible', image: 'https://images.unsplash.com/photo-1617788138017-80ad40651399?q=80&w=400&auto=format&fit=crop', daily_price: '$55/day'},
      {name: 'Sport', image: 'https://images.unsplash.com/photo-1544636331-e26879cd4d9b?q=80&w=400&auto=format&fit=crop', daily_price: '$75/day'},
      {name: 'Luxury', image: 'https://images.unsplash.com/photo-1563720223185-11003d516935?q=80&w=400&auto=format&fit=crop', daily_price: '$120/day'},
      {name: 'Electric', image: 'https://images.unsplash.com/photo-1560958089-b8a1929cea89?q=80&w=400&auto=format&fit=crop', daily_price: '$45/day'}
    ]

    # Use centralized brand mapping from Car model (slug, name, image under app/assets/images/brands)
    @brand_logos = Car.brand_logos
  end
end