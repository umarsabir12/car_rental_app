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
    document_pending
    document_approved
    document_rejected
    payment_received
    payment_failed
    profile_updated
    car_viewed
    registration_completed
    vendor_registration
    vendor_activated
    vendor_deactivated
    car_added
    car_updated
    car_deleted
    vendor_deleted
    vendor_restored
    car_document_approved
    car_document_rejected
    vendor_document_approved
    vendor_document_rejected
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
    created_at.strftime("%b %d, %Y at %I:%M %p")
  end

  def action_icon
    case action
    when "booking_created", "booking_confirmed", "booking_cancelled"
      "fas fa-calendar-check"
    when "document_uploaded", "document_pending", "document_approved", "document_rejected", "car_document_approved", "car_document_rejected", "vendor_document_approved", "vendor_document_rejected"
      "fas fa-file-upload"
    when "payment_completed", "payment_failed"
      "fas fa-credit-card"
    when "car_viewed", "car_added", "car_updated", "car_deleted"
      "fas fa-car"
    when "registration_completed", "vendor_registration", "vendor_restored"
      "fas fa-user-plus"
    when "vendor_deleted"
      "fas fa-user-times"
    else
      "fas fa-circle"
    end
  end

  def action_color
    case action
    when "booking_created", "document_uploaded", "document_pending", "payment_completed", "registration_completed", "vendor_registration", "car_added", "vendor_restored", "car_document_approved", "vendor_document_approved"
      "text-blue-600"
    when "booking_confirmed", "document_approved", "car_updated"
      "text-green-600"
    when "booking_cancelled", "document_rejected", "payment_failed", "car_deleted", "vendor_deleted", "car_document_rejected", "vendor_document_rejected"
      "text-red-600"
    when "profile_updated", "car_viewed"
      "text-purple-600"
    else
      "text-gray-600"
    end
  end

  def actor_name
    if user.present?
      user.full_name
    elsif vendor.present?
      vendor.company_name
    else
      "System"
    end
  end

  def actor_type
    if user.present?
      "User"
    elsif vendor.present?
      "Vendor"
    else
      "System"
    end
  end

  private

  def user_or_vendor_present
    errors.add(:base, "Either user or vendor must be present") unless user.present? || vendor.present?
  end
end
