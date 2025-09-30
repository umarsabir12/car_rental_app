class Vendor < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :cars, dependent: :destroy
  has_many :activities, dependent: :destroy
  has_many_attached :avatar

  validates :email, :company_name, :first_name, :last_name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, if: :email?
  validates :website, format: { with: URI::regexp(%w[http https]) }, allow_blank: true
  validates :company_logo, format: { with: URI::regexp(%w[http https]) }, allow_blank: true

  # Emirates ID validations
  validates :emirates_id, format: { with: /\A\d{15}\z/ }, allow_blank: true
  validate :emirates_id_expiry_in_future

  after_create :log_vendor_registration
  after_update :log_vendor_profile_update, if: :saved_change_to_company_name?

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
end
