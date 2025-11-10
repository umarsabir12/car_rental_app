class VendorRequestsController < ApplicationController
  before_action :set_page_data

  def new
    @vendor_request = VendorRequest.build
  end
  
  def create
    @vendor_request = VendorRequest.build(vendor_request_params)
    
    if @vendor_request.save
      VendorMailer.request_email(@vendor_request.id).deliver_now
      redirect_to vendor_hub_path, notice: 'Your request has been submitted successfully! We will review it and get back to you soon.'
    else
      flash.now[:alert] = "Please fix the following errors:\n#{@vendor_request.errors.full_messages.join(', ')}"
      render :new, status: :unprocessable_entity
    end
  end
  
  private

  def set_page_data
    @social_links = {'Facebook' => AppConstants::FACEBOOK, 'Instagram' => AppConstants::INSTAGRAM, 'Twitter' => AppConstants::TWITTER, 'YouTube' => AppConstants::YOUTUBE}

    @why_join_items = [
      { title: "Reach More Customers", desc: "Put your cars in front of thousands of renters across UAE." },
      { title: "Boost Revenue", desc: "More bookings, more income, no extra marketing hassle." },
      { title: "Easy Fleet Management", desc: "Update, manage and track your vehicles in real time." },
      { title: "Confirmed Bookings", desc: "Secure verified reservations directly through the platform." },
      { title: "Zero Commission", desc: "Keep 100% of your earnings. No fees, no hidden charges, just a monthly subscription." }
    ]

    @faqs = [
      {
        question: 'What is the core revenue model for partners on Wheels on Rent?',
        answer: 'Our model is a revolutionary, Zero Commission structure. Partners pay a fixed subscription fee based on their chosen advertising package (e.g., Pro Max) and keep 100% of the rental income from all direct bookings generated through our platform.'
      },
      {
        question: 'How do you justify the subscription fee if there is no commission?',
        answer: 'The subscription fee is a guaranteed investment in High-Volume Lead Generation and unparalleled market visibility. It covers our advanced SEO and marketing efforts to ensure your listings dominate searches for keywords like (Car Rental Dubai), directly resulting in a continuous flow of high-intent customer inquiries to you.'
      },
      {
        question: 'What is the expected Return on Investment (ROI) for a new partner?',
        answer: 'While ROI varies based on fleet utilization and pricing, partners consistently report a rapid and significant ROI due to two factors: 1) Elimination of Broker Commissions (saving up to 30% per booking) and 2) Increased Fleet Utilization Rate driven by our targeted marketing. The goal is for the subscription fee to be covered by the profit from just a few extra bookings.'
      },
      {
        question: 'Do you handle the payment processing or invoicing?',
        answer: 'No. To maintain the zero-commission model and ensure your control, all financial transactions, including payment processing, invoicing, and security deposits, are handled directly by your company with the renter.'
      },
      {
        question: 'Are there any hidden fees, charges, or transaction costs?',
        answer: 'Absolutely not. Our pricing is transparent. There are no hidden fees, no per-click charges, and no transactional costs beyond your chosen fixed monthly or annual subscription package.'
      },
      {
        question: 'How quickly can I get my fleet listed and start receiving leads?',
        answer: 'The onboarding process is fast-tracked. Once your registration and legal documentation are verified, your dedicated account manager can have your core fleet listings active and generating inquiries within 24 to 48 hours.'
      },
      {
        question: 'How often can I update my pricing and availability?',
        answer: 'Pricing, availability, mileage, and vehicle details can be updated instantly and unlimitedly via your dedicated partner dashboard. This allows you to implement dynamic pricing strategies and respond immediately to market demand.'
      },
      {
        question: 'How are customer leads delivered to my company?',
        answer: 'Leads are delivered directly to your designated sales team through multiple channels chosen by the customer, including direct phone calls, WhatsApp messages, and email inquiries, ensuring rapid and high-conversion contact.'
      },
      {
        question: 'Do you support specific vehicle categories like Luxury, Exotic, or Commercial vehicles?',
        answer: 'Yes. Our platform is designed to handle all categories, with specialized filters to promote Luxury Car Rental (e.g., BMW, Porsche), Exotic Supercars, SUVs, and even commercial vans or Long-Term Lease vehicles, ensuring you reach the right niche market.'
      },
      {
        question: 'Do I get access to customer data and booking analytics?',
        answer: 'Yes. Unlike brokers, we ensure you own the customer relationship. Your partner dashboard provides full access to performance metrics, including listing views, inquiry rates, and geographical lead origins, empowering data-driven decisions.'
      },
      {
        question: 'Who is eligible to partner with Wheels on Rent?',
        answer: 'We partner exclusively with legally registered businesses, including established Car Rental Companies, licensed car brokers, and fleet management service providers with a valid commercial license and a physical office in the region of operation (UAE, Saudi Arabia, etc.).'
      },
      {
        question: 'Can a small or independent rental agency join the platform?',
        answer: 'Absolutely. Our flexible packages, starting with the (Starter Pro) tier, are specifically designed to empower smaller, independent agencies to gain the same market visibility as major players without the prohibitive commission costs.'
      },
      {
        question: 'Do you provide support or training for my sales team?',
        answer: 'Yes. Every Pro Max and Enterprise partner receives comprehensive training on maximizing the use of our dashboard and a dedicated Account Manager who provides ongoing strategic advice to maximize your returns and lead conversion.'
      },
      {
        question: 'Do I need to be exclusive to Wheels on Rent?',
        answer: 'No. While we are confident in the value we deliver, we do not require exclusivity. You are free to list your fleet on other channels, but we encourage you to prioritize our Zero-Commission platform for higher profitability.'
      },
      {
        question: 'What measures are in place to ensure lead quality and prevent spam?',
        answer: 'We utilize advanced proprietary filtering algorithms to verify inquiry authenticity and actively monitor lead quality. Our focus is on delivering High-Intent Leads from customers actively searching for immediate Car Hire services, significantly reducing time wasted on non-serious inquiries.'
      }
    ]
  end
  
  def vendor_request_params
    params.require(:vendor_request).permit(:first_name, :last_name, :email, :phone, :vehicle_count)
  end
end