class Notification < ApplicationRecord
  belongs_to :admin

  validates :title, presence: true
  validates :message, presence: true
  validates :related_path, presence: true

  scope :unread, -> { where(read_at: nil) }
  scope :read, -> { where.not(read_at: nil) }
  scope :ordered, -> { order("read_at ASC NULLS FIRST, created_at DESC") }

  after_create_commit :broadcast_notification
  after_update_commit :broadcast_notification_status, if: :saved_change_to_read_at?

  def read?
    read_at.present?
  end

  def unread?
    read_at.nil?
  end

  def mark_as_read!
    update(read_at: Time.current) unless read?
  end

  private

  def broadcast_notification
    # Broadcast the new notification to the dropdown list
    broadcast_prepend_later_to(
      "admin_#{admin_id}_notifications",
      target: "notificationsList",
      partial: "admin/notifications/notification",
      locals: { notification: self }
    )

    # Remove the empty state message if it exists
    broadcast_remove_to(
      "admin_#{admin_id}_notifications",
      target: "empty-notifications-state"
    )

    # Broadcast to update the bell icon pill
    broadcast_replace_later_to(
      "admin_#{admin_id}_notifications",
      target: "notificationCountPill",
      partial: "admin/notifications/count",
      locals: { count: admin.notifications.unread.count }
    )
  end

  def broadcast_notification_status
    # Update the visual status of this specific notification in the dropdown
    broadcast_replace_later_to(
      "admin_#{admin_id}_notifications",
      target: "notification_#{id}",
      partial: "admin/notifications/notification",
      locals: { notification: self }
    )

    # Update the overall bell icon pill count
    broadcast_replace_later_to(
      "admin_#{admin_id}_notifications",
      target: "notificationCountPill",
      partial: "admin/notifications/count",
      locals: { count: admin.notifications.unread.count }
    )
  end
end
