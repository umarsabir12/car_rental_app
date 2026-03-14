module AppConstants
  CAR_CATEGORIES = [ [ "Economy", "Economy" ], [ "SUV", "SUV" ], [ "Limousine", "Limousine" ], [ "Sports", "Sports" ], [ "Luxury", "Luxury" ], [ "Electric", "Electric" ], [ "Convertible", "Convertible" ], [ "Hybrid", "Hybrid" ], [ "Van", "Van" ], [ "Truck", "Truck" ] ].freeze
  ADMIN_WHATSAPP_NUMBER = "+971506336408"
  FACEBOOK = "https://www.facebook.com/wheelsonrent.ae"
  YOUTUBE = "https://www.youtube.com/@WheelsonRentUAE"
  INSTAGRAM = "https://www.instagram.com/wheelsonrent.ae/"
  TWITTER = "https://x.com/WheelsOnRentUAE"
  TIKTOK = "https://www.tiktok.com/@wheelsonrent"


  CAR_CATEGORIES_META = {
    "suv" => {
      title: "SUV Rental Dubai & UAE | Rent Luxury SUVs & 4x4 Cars",
      description: "Book the best SUV rental in Dubai and UAE with Wheels on Rent. Choose from a wide selection of luxury SUVs, 4x4, and economy vehicles at the lowest prices. Get instant confirmation."
    },
    "economy" => {
      title: "Economy Car Rental Dubai | Cheap Car Hire - Wheels on Rent",
      description: "Book affordable economy cars in Dubai from AED 70/day with Wheels on Rent. Flexible daily & monthly rentals, no deposit options, ideal for tourists & residents."
    },
    "sports" => {
      title: "Sports Car Rental Dubai | Luxury & Exotic Car Hire - Wheels on Rent",
      description: "Rent luxury and exotic sports cars in Dubai | high-performance vehicles, premium service, and flexible rental packages from Wheels on Rent."
    },
    "luxury" => {
      title: "Luxury Car Rental Dubai | Premium Car Hire - Wheels on Rent",
      description: "Experience luxury car rentals in Dubai with top-tier vehicles, premium service and flexible hire options from Wheels on Rent."
    },
    "electric" => {
      title: "Electric Car Rental Dubai | Eco-Friendly Car Hire - Wheels on Rent",
      description: "Rent electric cars in Dubai | eco-friendly, modern vehicles and convenient rental plans with Wheels on Rent."
    },
    "convertible" => {
      title: "Convertible Car Rental Dubai | Open-Top Car Hire - Wheels on Rent",
      description: "Enjoy Dubai in style with convertible car rentals. Open-top, fun rides and flexible hire packages from Wheels on Rent."
    },
    "hybrid" => {
      title: "Hybrid Car Rental Dubai | Green & Affordable Hire - Wheels on Rent",
      description: "Choose hybrid car rentals in Dubai | fuel-efficient, cost-effective options and flexible plans with Wheels on Rent."
    },
    "van" => {
      title: "Van Rental Dubai | Spacious Vehicle Hire - Wheels on Rent",
      description: "Rent spacious vans in Dubai for group travel or luggage | flexible rental options with Wheels on Rent."
    },
    "truck" => {
      title: "Truck Rental Dubai | Heavy-Duty Vehicle Hire - Wheels on Rent",
      description: "Rent trucks in Dubai for transport, moving or heavy-duty needs | reliable service and flexible rental packages from Wheels on Rent."
    }
  }.freeze

  CAR_BRANDS_META = {
    "mitsubishi" => {
      title: "Mitsubishi Car Rental Dubai | Affordable Hire - Wheels on Rent",
      description: "Rent Mitsubishi cars in Dubai at great rates with reliable service and flexible rental options."
    },
    "rolls-royce" => {
      title: "Rolls-Royce Rental Dubai | Luxury Chauffeur & Self-Drive - Wheels on Rent",
      description: "Experience premium Rolls-Royce rentals in Dubai | luxury, comfort, and top-tier service."
    },
    "aston-martin" => {
      title: "Aston Martin Rental Dubai | Luxury Sports Car Hire - Wheels on Rent",
      description: "Rent Aston Martin in Dubai for a luxury sports driving experience with flexible rental plans."
    },
    "bentley" => {
      title: "Bentley Rental Dubai | Premium Luxury Car Hire - Wheels on Rent",
      description: "Rent Bentley cars in Dubai | elegant luxury vehicles with top-quality service and flexible packages."
    },
    "lamborghini" => {
      title: "Lamborghini Rental Dubai | Supercar Hire - Wheels on Rent",
      description: "Drive a Lamborghini in Dubai with flexible rental options and premium service."
    },
    "mini" => {
      title: "Mini Cooper Rental Dubai | Stylish Compact Hire - Wheels on Rent",
      description: "Rent Mini Cooper cars in Dubai | stylish, compact, and perfect for city driving."
    },
    "chevrolet" => {
      title: "Chevrolet Car Rental Dubai | Affordable Hire - Wheels on Rent",
      description: "Rent Chevrolet cars in Dubai with great rates and reliable rental service."
    },
    "lexus" => {
      title: "Lexus Car Rental Dubai | Premium SUV & Sedan Hire - Wheels on Rent",
      description: "Rent Lexus luxury cars in Dubai | smooth performance and premium comfort."
    },
    "kia" => {
      title: "Kia Car Rental Dubai | Budget-Friendly Hire - Wheels on Rent",
      description: "Rent Kia cars in Dubai at affordable rates with flexible rental plans."
    },
    "cadillac" => {
      title: "Cadillac Rental Dubai | Luxury SUV Hire - Wheels on Rent",
      description: "Rent Cadillac SUVs in Dubai | luxury, comfort, and premium rental service."
    },
    "gmc" => {
      title: "GMC Car Rental Dubai | Powerful SUV Hire - Wheels on Rent",
      description: "Rent GMC SUVs in Dubai with spacious interiors and strong performance."
    },
    "audi" => {
      title: "Audi Car Rental Dubai | Luxury Car Hire - Wheels on Rent",
      description: "Rent Audi luxury cars in Dubai | premium performance and modern features."
    },
    "mazda" => {
      title: "Mazda Car Rental Dubai | Reliable & Affordable Hire - Wheels on Rent",
      description: "Rent Mazda cars in Dubai with great pricing and flexible rental options."
    },
    "land-rover" => {
      title: "Land Rover Rental Dubai | Luxury SUV Hire - Wheels on Rent",
      description: "Rent Land Rover SUVs in Dubai | premium off-road capability with superior comfort."
    },
    "nissan" => {
      title: "Nissan Car Rental Dubai | Affordable Daily & Monthly Hire - Wheels on Rent",
      description: "Rent Nissan cars in Dubai at competitive rates with flexible plans."
    },
    "bmw" => {
      title: "BMW Rental Dubai | Luxury Performance Car Hire - Wheels on Rent",
      description: "Rent BMW cars in Dubai | luxury performance vehicles with top-quality rental service."
    }
  }.freeze

  LOCATIONS = [
    { id: "dubai", name: "Dubai" },
    { id: "abu-dhabi", name: "Abu Dhabi" },
    { id: "sharjah", name: "Sharjah" },
    { id: "ajman", name: "Ajman" }
  ].freeze

  STATISTICS = [
    { value: "990+", label: "BOOKINGS", icon: "fa-calendar-check" },
    { value: "230+", label: "CARS", icon: "fa-car" },
    { value: "660+", label: "HAPPY CUSTOMER", icon: "fa-users" }
  ].freeze

  COMPANY_INFO = {
    name: "WheelsOnRent",
    blurb: "Enjoy great offers on budget and luxury rentals, chauffeur services, and limousines with WheelsOnRent. Headquartered in Dubai, serving all of the UAE"
  }.freeze

  CONTACT_INFO = {
    phone: "+971506336408",
    email: "booking@wheelsonrent.ae",
    address: "Building A1, Dubai Digital Park, Dubai Silicon Oasis, Dubai"
  }.freeze

  CAR_CLASSES = [
    { name: "Economy", image: "https://images.unsplash.com/photo-1552519507-da3b142c6e3d?q=80&w=400&auto=format&fit=crop", daily_price: "$20/day" },
    { name: "SUV", image: "https://images.unsplash.com/photo-1583121274602-3e2820c69888?q=80&w=400&auto=format&fit=crop", daily_price: "$35/day" },
    { name: "Convertible", image: "https://images.unsplash.com/photo-1617788138017-80ad40651399?q=80&w=400&auto=format&fit=crop", daily_price: "$55/day" },
    { name: "Sport", image: "https://images.unsplash.com/photo-1544636331-e26879cd4d9b?q=80&w=400&auto=format&fit=crop", daily_price: "$75/day" },
    { name: "Luxury", image: "https://images.unsplash.com/photo-1563720223185-11003d516935?q=80&w=400&auto=format&fit=crop", daily_price: "$120/day" },
    { name: "Electric", image: "https://images.unsplash.com/photo-1560958089-b8a1929cea89?q=80&w=400&auto=format&fit=crop", daily_price: "$45/day" }
  ].freeze

  CATEGORIES_TO_DISPLAY = [
    { name: "Featured Collection", slug: "featured", description: "Handpicked premium vehicles for your journey. Experience the best of Dubai with our top-rated cars." },
    { name: "Economy", slug: "Economy", description: "Enjoy budget-friendly car rentals with seasonal discounts from some of the best car rental Dubai companies." },
    { name: "Luxury", slug: "Luxury", description: "Experience the pinnacle of automotive excellence with our premium luxury vehicles, featuring top-tier comfort, advanced technology, and prestigious brands." },
    { name: "SUV", slug: "SUV", description: "From spacious 7-seaters to the latest 5-seater sports utility vehicles, rent an SUV for city drives or comfortable long hauls with ample seating and luggage space." },
    { name: "Sports", slug: "Sports", description: "Feel the thrill of high-performance sports cars with powerful engines, sleek designs, and exceptional handling for an unforgettable driving experience in Dubai." },
    { name: "Cars with Driver", slug: "with-driver", with_driver: true, description: "Sit back and relax while our professional chauffeurs take you to your destination in comfort and style. Perfect for business trips, events, or stress-free sightseeing." }
  ].freeze

  COMPANY_FEATURES = [
    { title: "Luxury and Premium Cars", description: "Enjoy Dubai in style with our luxury car rentals, including BMW 7 Series, Mercedes S-Class, and Audi A8. Perfect for business meetings, VIP events, or exploring Dubai’s skyline with elegance." },
    { title: "Sports and Exotic Cars", description: "For those seeking adrenaline, Wheels on Rent offers sports and exotic cars such as Ferrari, Lamborghini, and Porsche. These rentals are popular among tourists looking for a memorable Dubai driving experience or special occasions." },
    { title: "Electric Car Rentals in Dubai", description: "We provide eco-friendly options, including Tesla and other electric cars. Rent electric vehicles for sustainable and modern travel across Dubai and UAE, enjoying innovative technology and low environmental impact." },
    { title: "Car Rentals With Driver", description: "For convenience and comfort, rent a car with a professional driver. Our trained chauffeurs can guide you through Dubai’s best routes, tourist destinations, or corporate travel needs, ensuring a stress-free journey." },
    { title: "Self-Drive Car Rentals", description: "Experience freedom with self-drive rentals in Dubai. Explore the city and neighboring Emirates at your own pace, whether for tourism, shopping, or desert trips. All our cars are fully insured and maintained for safety." },
    { title: "Car Rentals for Tourism", description: "Tourists can access curated services to explore Dubai’s attractions, including Burj Khalifa, Dubai Mall, Palm Jumeirah, and desert safaris. We provide detailed guidance for sightseeing and optimal vehicle choice for Dubai tourist travel." },
    { title: "Family and SUV Rentals", description: "For family trips or group travel, Wheels on Rent offers spacious SUVs and family cars. These vehicles are perfect for road trips across UAE, desert excursions, or visiting Abu Dhabi, Sharjah, and Ras Al Khaimah." },
    { title: "Corporate Car Rentals in Dubai", description: "Businesses can benefit from our corporate car rental services. We offer long-term rentals, airport transfers, and executive cars to ensure punctuality, comfort, and professionalism for employees and clients." },
    { title: "Airport Car Rentals in Dubai", description: "Book a vehicle for Dubai International Airport pickups or departures. We provide fast delivery, flexible pick-up points, and a wide selection of cars, ensuring seamless travel for visitors and residents." },
    { title: "List Your Car and Earn", description: "Wheels on Rent allows vehicle owners to list their cars for rent, offering a reliable income source. Our platform handles bookings, insurance, and customer verification, making it safe and convenient to monetize your vehicle." },
    { title: "Safety and Maintenance", description: "All vehicles undergo regular inspections, sanitization, and maintenance. We provide road assistance, GPS tracking, and comprehensive insurance for peace of mind while driving across Dubai and UAE." },
    { title: "Flexible Rental Plans", description: "Whether you need a car for a few hours, days, or months, our flexible rental plans in Dubai cater to short-term or long-term needs. Daily, weekly, and monthly packages ensure cost-effective solutions for every traveler." },
    { title: "Explore Dubai at Your Own Pace", description: "Dubai is best explored at your own pace, and with Wheels on Rent, you can discover attractions like Dubai Marina, Jumeirah Beach, Al Fahidi Historical District, and Hatta mountains. Our vehicles provide a comfortable and efficient way to travel, combining convenience and freedom." },
    { title: "Affordable Pricing and Transparent Service", description: "We maintain competitive and transparent pricing for all cars, including economy, luxury, sports, and electric vehicles. There are no hidden fees, and all taxes, insurance, and delivery charges are included in the rental agreement." }
  ].freeze

  FAQ_CONTENT = [
    { question: "How can I book the car with Wheelsonrent?", answer: "<strong>Step 1:</strong> Browse and select your preferred car on our website.<br><strong>Step 2:</strong> Book online and make the payment securely.<br><strong>Step 3:</strong> Alternatively, contact us on WhatsApp or give us a call — our team will book the car for you.".html_safe },
    { question: "Can I rent a car in Dubai without a deposit?", answer: "Yes, Wheels on Rent provides zero deposit options for select vehicles." },
    { question: "Do you provide cars with drivers for tourists?", answer: "Yes, professional drivers are available for sightseeing, business trips, and airport transfers." },
    { question: "Can I rent electric or luxury cars?", answer: "Absolutely. Our fleet includes luxury, sports, and electric vehicles." },
    { question: "How do I list my car for rent?", answer: "Vehicle owners can submit their details on our website, and our team handles bookings, insurance, and payments. " },
    { question: "Are your cars insured and maintained?", answer: "All vehicles are fully insured, regularly serviced, and inspected before every rental." },
    { question: "Can I rent a car for a few hours or multiple days?", answer: "Yes, we offer flexible rental plans for hourly, daily, weekly, or monthly rentals." },
    { question: "Do you provide airport car rentals in Dubai?", answer: "Yes, we provide pickup and drop-off services at Dubai International Airport and other major airports." },
    { question: "Can a tourist rent a car in Dubai?", answer: "Yes, a tourist can easily rent a car in Dubai by providing us the required documents." },
    { question: "Can tourists book a rental car online in the UAE before arriving?", answer: "Yes, a tourist can easily rent a car in UAE by providing us the required documents." },
    { question: "What is the fuel policy?", answer: "The vehicle must be returned with the same amount of fuel as provided at pickup. A full tank at delivery means a full tank upon return." },
    { question: "Is your car rental service available in Sharjah?", answer: "Yes, we do offer rent a car in Sharjah like any other state of UAE." },
    { question: "Do you have both car option with and without driver?", answer: "Yes, we offer multiple options for both categories — cars with a driver and cars for self-drive (without a driver)." },
    { question: "Do you have free pick N drop while renting a car?", answer: "Some car rental companies provide free pick-up and drop-off, while others may charge a fee. However, for monthly bookings, delivery is usually free." },
    { question: "What is Salik and how much does it cost per crossing?", answer: "Salik is Dubai’s Road toll system managed by the RTA. It can be linked directly to the car’s plate number or through a windshield tag. Each Salik crossing costs AED 4. Some car rental companies may charge AED 5 per crossing to cover processing fees." },
    { question: "What is the requirement to rent a car in Dubai?", answer: "<strong>Tourists:</strong> Passport copy, Driving License, (IDP if required)<br><strong>GCC Nationals:</strong> GCC ID or Passport, GCC Driving License<br><strong>UAE Residents/Nationals:</strong> Emirates ID, UAE Driving License".html_safe },
    { question: "What is the car rental daily and monthly mileage policy?", answer: "For daily rentals, most car rental companies provide 250 KM per day. However, certain vehicles, especially sports cars, may come with a 200 KM daily limit. For monthly rentals, mileage limits typically range between 5,000 KM and 6,000 KM. Exact mileage limits are displayed with every car." },
    { question: "Which payment method car rental accept?", answer: "Each car rental company may offer different payment methods, and these are defined individually with each car listing. However, most car rental companies commonly accept Cash, Credit/Debit Cards, and even Cryptocurrency." }
  ].freeze

  SAMPLE_TESTIMONIALS = [
    {
      author_name: "Sarah Johnson",
      rating: 5,
      text: "Excellent service and great cars. Made my business trip much more comfortable!",
      relative_time_description: "a month ago"
    },
    {
      author_name: "Mike Chen",
      rating: 5,
      text: "Easy booking process and the car was in perfect condition. Highly recommended!",
      relative_time_description: "2 months ago"
    },
    {
      author_name: "Emma Davis",
      rating: 5,
      text: "Best car rental experience I have had. Will definitely use again.",
      relative_time_description: "3 weeks ago"
    }
  ].freeze
end
