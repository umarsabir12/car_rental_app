class Vendors::PasswordsController < Devise::PasswordsController
  # GET /resource/password/new
  def new
    super
  end

  # POST /resource/password
  def create
    super do |resource|
      if resource.errors.empty?
        flash[:notice] = "Password reset instructions have been sent to your email address."
      else
        flash[:alert] = "Email address not found. Please check and try again."
      end
    end
  end

  # GET /resource/password/edit?reset_password_token=abcdef
  def edit
    super
  end

  # PUT /resource/password
  def update
    super do |resource|
      if resource.errors.empty?
        flash[:notice] = "Your password has been successfully updated."
      else
        flash[:alert] = "Password reset failed. Please check the errors below."
      end
    end
  end

  protected

  def after_resetting_password_path_for(resource)
    new_vendor_session_path
  end

  def after_sending_reset_password_instructions_path_for(resource_name)
    new_vendor_password_path
  end
end
