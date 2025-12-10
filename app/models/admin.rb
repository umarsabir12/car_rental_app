class Admin < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Validations
  validates :first_name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :last_name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role_type, presence: true, inclusion: { in: %w[admin super_admin], message: "must be either 'admin' or 'super_admin'" }

  # Scopes
  scope :super_admins, -> { where(role_type: "super_admin") }
  scope :admins, -> { where(role_type: "admin") }

  # Instance methods
  def full_name
    "#{first_name} #{last_name}".strip
  end

  def display_name
    if first_name.present? && last_name.present?
      full_name
    elsif first_name.present?
      first_name
    else
      email.split("@").first
    end
  end

  def super_admin?
    role_type == "super_admin"
  end

  def can_create_admins?
    super_admin?
  end

  def role_display
    role_type.titleize
  end
end
