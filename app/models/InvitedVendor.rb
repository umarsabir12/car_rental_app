class InvitedVendor < ApplicationRecord
  after_create :send_invite_email

  def send_invite_email
    begin
      self.update(invite_sent: true, invite_token: SecureRandom.hex(10))
      Rails.logger.info "Sending invite email to #{self.email} with token #{self.invite_token}"
      VendorMailer.invite_email(self).deliver_now
      Rails.logger.info "Invite email sent successfully to #{self.email}"
    rescue => e
      Rails.logger.error "Failed to send invite email to #{self.email}: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      raise e
    end
  end
end
