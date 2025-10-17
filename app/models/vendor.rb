class Vendor < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :cars, dependent: :destroy
  has_many :activities, dependent: :destroy
  has_many :invoices, dependent: :destroy
  has_one :vendor_document
  has_many_attached :avatar

  # Normalization happens before validation
  before_validation :normalize_whatsapp_number, if: :whatsapp_number_changed?

  validates :email, :company_name, :first_name, :last_name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, if: :email?
  validates :website, format: { with: URI::regexp(%w[http https]) }, allow_blank: true
  validates :company_logo, format: { with: URI::regexp(%w[http https]) }, allow_blank: true
  # Emirates ID validations
  validates :emirates_id, format: { with: /\A\d{15}\z/ }, allow_blank: true
  validate :emirates_id_expiry_in_future
  # Whatsapp number validations
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

  
  after_create :log_vendor_registration
  after_update :log_vendor_profile_update, if: :saved_change_to_company_name?
  
  # Soft delete functionality
  scope :active, -> { where(deleted_at: nil) }
  scope :deleted, -> { where.not(deleted_at: nil) }
  
  # Payment mode enum
  enum payment_mode: { CreditCard: 0, AmericanExpress: 1 }, _default: :CreditCard

  def soft_delete!
    update!(deleted_at: Time.current)
  end

  def restore!
    update!(deleted_at: nil)
  end

  def deleted?
    deleted_at.present?
  end

  def active?
    deleted_at.nil?
  end

  scope :with_expired_emirates_id, -> {
    where.not(emirates_id: [nil, ""]).where("emirates_id_expires_on < ?", Date.current)
  }

  def name
    "#{first_name} #{last_name}"
  end

  def full_name
    name
  end

  def display_name
    company_name.present? ? company_name : name
  end

  def emirates_id_valid?
    emirates_id.present? && emirates_id.match?(/\A\d{15}\z/)
  end

  def emirates_id_expired?
    emirates_id_expires_on.present? && emirates_id_expires_on < Date.current
  end

  # Memoized parsed phone object for performance
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

  def total_pending_amount
    invoices.pending.sum(:amount)
  end

  def total_paid_amount
    invoices.paid.sum(:amount)
  end

  private

  def emirates_id_expiry_in_future
    return if emirates_id_expires_on.blank?
    if emirates_id_expires_on <= Date.current
      errors.add(:emirates_id_expires_on, "must be in the future")
    end
  end

  def log_vendor_registration
    Activity.log_activity(
      vendor: self,
      subject: self,
      action: 'vendor_registration',
      description: "New vendor registered: #{company_name} (#{email})",
      metadata: { 
        company_name: company_name,
        email: email,
        phone: phone
      }
    )
  end

  def log_vendor_profile_update
    Activity.log_activity(
      vendor: self,
      subject: self,
      action: 'vendor_profile_updated',
      description: "#{company_name} updated their profile",
      metadata: { 
        previous_company_name: company_name_before_last_save,
        new_company_name: company_name
      }
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
