class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :bookings, dependent: :destroy
  has_many :documents
  has_many :activities, dependent: :destroy
  
  before_validation :normalize_whatsapp_number, if: :whatsapp_number_changed?

  # Validations
  validates :first_name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :last_name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, presence: true, format: { with: /\A\+?[\d\s\-\(\)]+\z/, message: "must be a valid phone number" }
  validates :nationality, presence: true, inclusion: { in: %w[resident tourist], message: "must be either 'resident' or 'tourist'" }
  validates :terms_accepted, acceptance: { message: "must be accepted to use our services" }
  validates :whatsapp_number,
            phone: {
              possible: true,
              allow_blank: true,
              types: [:mobile, :fixed_or_mobile],
              message: :invalid_phone
            } 
  validates :whatsapp_number,
            uniqueness: { case_sensitive: false },
            allow_blank: true,
            if: :whatsapp_number_changed?
  validate :whatsapp_number_requirements, if: :whatsapp_number?


  after_create :create_documents, :log_registration
  
  def full_name
    "#{self.first_name} #{self.last_name}"
  end

  def display_name
    if first_name.present? && last_name.present?
      full_name
    elsif first_name.present?
      first_name
    else
      email.split('@').first
    end
  end

  def booking_alert
    required_docs = nationality == "resident" ? Document::RESIDENT : Document::TOURIST
    user_docs = documents.where(doc_name: required_docs)
    statuses = user_docs.pluck(:status)
    statuses.size < required_docs.size || statuses.include?("reject")
  end


  def has_required_pending_document?
    doc_names = nationality == "resident" ? Document::RESIDENT : Document::TOURIST
    documents.where(user_id: self.id, doc_name: doc_names, status: "pending").exists?
  end

  def create_documents
    doc_names = nationality == "resident" ? Document::RESIDENT : Document::TOURIST
    doc_names.each do |doc_name|
      documents.create!(doc_name: doc_name, document_type: self.nationality == 'resident' ? 'Resident' : 'Tourist', status: 'not uploaded')
    end
  end

  def document_alert_message
    docs = documents.to_a
    has_pending_booking = bookings.where(status: 'pending').exists?
    return nil unless has_pending_booking
    if docs.any? { |d| d.status == 'rejected' }
      'Some of your documents have been rejected. Please review and re-upload them to proceed with your booking.'
    else
      nil
    end
  end

  # Notification helper methods
  def missing_documents
    documents.where(status: 'not uploaded')
  end

  def pending_documents
    documents.where(status: 'pending')
  end

  def rejected_documents
    documents.where(status: 'rejected')
  end

  def approved_documents
    documents.where(status: 'approved')
  end

  def unpaid_bookings
    bookings.where(payment_processed: [false, nil])
  end

  def failed_payments
    Transaction.joins(:booking).where(bookings: { user_id: id }, status: 'failed')
  end

  def document_completion_percentage
    total_required = nationality == "resident" ? Document::RESIDENT.count : Document::TOURIST.count
    approved_count = approved_documents.count
    return 0 if total_required == 0
    ((approved_count.to_f / total_required) * 100).round
  end

  def has_notifications?
    missing_documents.any? || pending_documents.any? || rejected_documents.any? || unpaid_bookings.any? || failed_payments.any?
  end

  def parsed_whatsapp
    return nil if whatsapp_number.blank?
    @parsed_whatsapp ||= Phonelib.parse(whatsapp_number)
  end
  
  # Get formatted number for display
  def whatsapp_display
    parsed_whatsapp&.international || whatsapp_number
  end
  
  # Get E164 format for API calls (WhatsApp Business API, Twilio, etc.)
  def whatsapp_e164
    parsed_whatsapp&.e164
  end
  
  # Get national format
  def whatsapp_national
    parsed_whatsapp&.national
  end
  
  # Get country information
  def whatsapp_country
    parsed_whatsapp&.country
  end
  
  # Check if it's a valid mobile number
  def whatsapp_mobile?
    return false if whatsapp_number.blank?
    parsed = parsed_whatsapp
    parsed.valid? && (parsed.type == :mobile || parsed.type == :fixed_or_mobile)
  end
  
  # WhatsApp link generator
  def whatsapp_link(message = nil)
    return nil unless whatsapp_e164
    base_url = "https://wa.me/#{whatsapp_e164.delete('+')}"
    message ? "#{base_url}?text=#{ERB::Util.url_encode(message)}" : base_url
  end

  private

  def log_registration
    Activity.log_activity(
      user: self,
      subject: self,
      action: 'registration_completed',
      description: "New user registered: #{full_name} (#{email})",
      metadata: { nationality: nationality, phone: phone }
    )
  end

  def normalize_whatsapp_number
    return if whatsapp_number.blank?
    
    # Parse and normalize to E164 format
    parsed = Phonelib.parse(whatsapp_number)
    
    if parsed.valid?
      self.whatsapp_number = parsed.e164
      self.whatsapp_country_code = parsed.country_code
      # Clear memoization
      @parsed_whatsapp = nil
    else
      # Try to clean the number
      cleaned = whatsapp_number.to_s.gsub(/[^\d+]/, '')
      cleaned = "+#{cleaned}" unless cleaned.start_with?('+')
      
      reparsed = Phonelib.parse(cleaned)
      if reparsed.valid?
        self.whatsapp_number = reparsed.e164
        self.whatsapp_country_code = reparsed.country_code
        @parsed_whatsapp = nil
      end
    end
  end
  
  def whatsapp_number_requirements
    return if whatsapp_number.blank?
    
    parsed = parsed_whatsapp
    
    unless parsed.valid?
      errors.add(:whatsapp_number, :invalid_format)
      return
    end
    
    # WhatsApp requires mobile numbers (some countries allow landline)
    unless parsed.types.include?(:mobile) || parsed.types.include?(:fixed_or_mobile)
      errors.add(:whatsapp_number, :must_be_mobile)
    end
    
    # Additional length check (WhatsApp specific)
    unless whatsapp_number.length.between?(8, 16)
      errors.add(:whatsapp_number, :invalid_length)
    end
  end
end
