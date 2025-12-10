class Vendors::SessionsController < Devise::SessionsController
  # You can add custom logic here if needed
  # For now, just use Devise defaults

  def new
    super
  end

  def create
    self.resource = warden.authenticate!(auth_options)
    set_flash_message!(:notice, :signed_in)
    sign_in(resource_name, resource)
    yield resource if block_given?
    respond_with resource, location: after_sign_in_path_for(resource)
  rescue => e
    # Check if the failure is due to inactive account
    vendor = Vendor.find_by(email: params[:vendor][:email])
    if vendor && !vendor.is_active?
      flash[:alert] = "Your account has been deactivated. Please contact the administrator for support at support@example.com"
      redirect_to new_vendor_session_path
    else
      super
    end
  end

  def destroy
    super
  end
end
