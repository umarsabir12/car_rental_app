class InvitedVendor < ApplicationRecord
  
    after_create :send_invite_email

    def send_invite_email
        self.update(invite_sent: true, invite_token: SecureRandom.hex(10))
        VendorMailer.invite_email(self).deliver_later
    end
end