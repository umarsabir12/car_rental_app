class Activity < ApplicationRecord
  belongs_to :user
  belongs_to :subject, polymorphic: true

  # Activity types
  ACTIONS = %w[
    booking_created
    booking_confirmed
    booking_cancelled
    booking_assigned
    document_uploaded
    document_approved
    document_rejected
    payment_completed
    payment_failed
    profile_updated
    car_viewed
    registration_completed
  ].freeze

  validates :action, inclusion: { in: ACTIONS }
  validates :action, :description, presence: true

  scope :recent, -> { order(created_at: :desc) }
  scope :by_action, ->(action) { where(action: action) }
  scope :by_user, ->(user) { where(user: user) }

  def self.log_activity(user:, subject:, action:, description:, metadata: nil, request: nil)
    create!(
      user: user,
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
    when 'booking_created', 'booking_confirmed', 'booking_cancelled', 'booking_assigned'
      'fas fa-calendar-check'
    when 'document_uploaded', 'document_approved', 'document_rejected'
      'fas fa-file-upload'
    when 'payment_completed', 'payment_failed'
      'fas fa-credit-card'
    when 'profile_updated'
      'fas fa-user-edit'
    when 'car_viewed'
      'fas fa-car'
    when 'registration_completed'
      'fas fa-user-plus'
    else
      'fas fa-circle'
    end
  end

  def action_color
    case action
    when 'booking_created', 'document_uploaded', 'payment_completed', 'registration_completed'
      'text-blue-600'
    when 'booking_confirmed', 'document_approved', 'booking_assigned'
      'text-green-600'
    when 'booking_cancelled', 'document_rejected', 'payment_failed'
      'text-red-600'
    when 'profile_updated', 'car_viewed'
      'text-purple-600'
    else
      'text-gray-600'
    end
  end
end
