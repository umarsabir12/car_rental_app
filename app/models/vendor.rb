class Vendor < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :cars, dependent: :destroy

  has_many_attached :avatar

  validates :email, :company_name, :first_name, :last_name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, if: :email?
  validates :website, format: { with: URI::regexp(%w[http https]) }, allow_blank: true
  validates :company_logo, format: { with: URI::regexp(%w[http https]) }, allow_blank: true

  def name
    "#{first_name} #{last_name}"
  end

  def full_name
    name
  end

  def display_name
    company_name.present? ? company_name : name
  end
end
