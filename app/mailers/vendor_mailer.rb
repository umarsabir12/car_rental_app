class VendorMailer < ApplicationMailer
  # Remove the hardcoded from address - will use ApplicationMailer's default

  def invite_email(vendor)
    @vendor = vendor
    @login_url = new_vendor_registration_url(token: @vendor.invite_token)
    
    Rails.logger.info "VendorMailer: Sending invite email to #{@vendor.email}"
    Rails.logger.info "VendorMailer: Login URL: #{@login_url}"
    Rails.logger.info "VendorMailer: From address: #{ApplicationMailer.default[:from]}"
    
    mail(
      to: @vendor.email, 
      subject: 'You have been invited to join WheelsOnRent as a Vendor'
    )
  end

  def emirates_id_expired_email(vendor)
    @vendor = vendor
    mail(
      to: @vendor.email,
      subject: 'Your Emirates ID has expired – action required'
    )
  end

  def reject_email(vendor_email, first_name, last_name)

    @first_name = first_name
    @last_name = last_name
    
    Rails.logger.info "VendorMailer: Sending reject email to #{vendor_email}"
    Rails.logger.info "VendorMailer: From address: #{ApplicationMailer.default[:from]}"
    
    mail(
      to: vendor_email, 
      subject: 'Your request have been rejected to join WheelsOnRent as a Vendor'
    )
  end

  def request_email(vendor_request_id)

    vendor_request = VendorRequest.find_by_id(vendor_request_id)
    @vendor_request = vendor_request
    
    mail(
      to: ENV['FROM_EMAIL'], 
      subject: 'New request to join WheelsOnRent as a Vendor'
    )
  end
end 