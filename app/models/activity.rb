class Activity < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :vendor, optional: true
  belongs_to :subject, polymorphic: true

  # Activity types
  ACTIONS = %w[
    booking_created
    booking_confirmed
    booking_cancelled
    document_uploaded
    document_approved
    document_rejected
    payment_completed
    payment_failed
    profile_updated
    car_viewed
    registration_completed
    vendor_registration
    car_added
    car_updated
    car_deleted
  ].freeze

  validates :action, inclusion: { in: ACTIONS }
  validates :action, :description, presence: true
  validate :user_or_vendor_present

  scope :recent, -> { order(created_at: :desc) }
  scope :by_action, ->(action) { where(action: action) }
  scope :by_user, ->(user) { where(user: user) }
  scope :by_vendor, ->(vendor) { where(vendor: vendor) }
  scope :user_activities, -> { where.not(user_id: nil) }
  scope :vendor_activities, -> { where.not(vendor_id: nil) }

  def self.log_activity(user: nil, vendor: nil, subject:, action:, description:, metadata: nil, request: nil)
    create!(
      user: user,
      vendor: vendor,
      subject: subject,
      action: action,
      description: description,
      metadata: metadata&.to_json,
      ip_address: request&.remote_ip,
      user_agent: request&.user_agent
    )
  end

  def metadata_hash
    return {} if metadata.blank?
    JSON.parse(metadata)
  rescue JSON::ParserError
    {}
  end

  def formatted_time
    created_at.strftime('%b %d, %Y at %I:%M %p')
  end

  def action_icon
    case action
    when 'booking_created', 'booking_confirmed', 'booking_cancelled'
      'fas fa-calendar-check'
    when 'document_uploaded', 'document_approved', 'document_rejected'
      'fas fa-file-upload'
    when 'payment_completed', 'payment_failed'
      'fas fa-credit-card'
    when 'car_viewed', 'car_added', 'car_updated', 'car_deleted'
      'fas fa-car'
    when 'registration_completed', 'vendor_registration'
      'fas fa-user-plus'
    else
      'fas fa-circle'
    end
  end

  def action_color
    case action
    when 'booking_created', 'document_uploaded', 'payment_completed', 'registration_completed', 'vendor_registration', 'car_added'
      'text-blue-600'
    when 'booking_confirmed', 'document_approved', 'car_updated'
      'text-green-600'
    when 'booking_cancelled', 'document_rejected', 'payment_failed', 'car_deleted'
      'text-red-600'
    when 'profile_updated', 'car_viewed', 'vendor_profile_updated'
      'text-purple-600'
    else
      'text-gray-600'
    end
  end

  def actor_name
    if user.present?
      user.full_name
    elsif vendor.present?
      vendor.company_name
    else
      'System'
    end
  end

  def actor_type
    if user.present?
      'User'
    elsif vendor.present?
      'Vendor'
    else
      'System'
    end
  end

  private

  def user_or_vendor_present
    unless user.present? || vendor.present?
      errors.add(:base, 'Either user or vendor must be present')
    end
  end
end
