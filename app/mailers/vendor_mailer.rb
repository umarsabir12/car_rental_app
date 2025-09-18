class VendorMailer < ApplicationMailer
  default from: 'no-reply@wheelsonrent.com'

  def invite_email(vendor)
    @vendor = vendor
    @login_url = new_vendor_registration_url(token: @vendor.invite_token)
    mail(to: @vendor.email, subject: 'You have been invited to join WheelsOnRent as a Vendor')
  end

  def emirates_id_expired_email(vendor)
    @vendor = vendor
    mail(
      to: @vendor.email,
      subject: 'Your Emirates ID has expired – action required'
    )
  end
end 