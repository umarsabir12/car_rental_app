class VendorMailer < ApplicationMailer
  default from: 'no-reply@wheelsonrent.com'

  def invite_email(vendor, password)
    @vendor = vendor
    @password = password
    @login_url = new_vendor_session_url
    mail(to: @vendor.email, subject: 'You have been invited to join WheelsOnRent as a Vendor')
  end
end 