class Announcement < ApplicationRecord
  # We only ever want one announcement in this simplified version.
  # This helper always returns the first record, creating one if it doesn't exist.
  def self.current
    first_or_create!(active: true, message: "Welcome to Wheels On Rent!")
  end

  def visible?
    active? && (ends_at.blank? || ends_at > Time.current) && message.present?
  end

  # Helper to check if it's "permanent" (no expiry set)
  def permanent?
    ends_at.blank?
  end
end
