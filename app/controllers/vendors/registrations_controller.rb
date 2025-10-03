class Vendors::RegistrationsController <  Devise::RegistrationsController
  before_action :check_invite_token, only: [:new]

  def new
    if @invited_vendor.present?
      @vendor = Vendor.new(email: @invited_vendor.email, first_name: @invited_vendor.first_name, last_name: @invited_vendor.last_name)
    else
      # Redirect to login page if no valid invite token
      redirect_to new_vendor_session_path, alert: "You need a valid invitation link to register as a vendor"
    end
  end

  def create
    @invited_vendor = InvitedVendor.find_by(invite_token: params[:invite_token])
    unless @invited_vendor.present? && @invited_vendor.expires_at > Time.current
      redirect_to new_vendor_session_path, alert: "Invalid or expired invite token" and return
    end

    @vendor = Vendor.new(vendor_params.merge(email: @invited_vendor.email, first_name: @invited_vendor.first_name, last_name: @invited_vendor.last_name))
    if @vendor.save
      @invited_vendor.update(status: "accepted", invite_token: nil)
      sign_in(@vendor)
      redirect_to vendor_path(@vendor), notice: "Vendor created successfully"
    else
      render :new, alert: "Vendor creation failed"
    end
  end

  private

  def vendor_params
    params.require(:vendor).permit(:email, :first_name, :last_name, :password, :password_confirmation, :company_name, :invite_token, :payment_mode)
  end

  def check_invite_token
    if params[:token].present?
      Rails.logger.info "Checking invite token: #{params[:token]}"
      @invited_vendor = InvitedVendor.find_by(invite_token: params[:token])
      Rails.logger.info "Found invited vendor: #{@invited_vendor.inspect}"
      
      if @invited_vendor.present?
        Rails.logger.info "Token expires at: #{@invited_vendor.expires_at}"
        Rails.logger.info "Current time: #{Time.current}"
        Rails.logger.info "Token valid: #{@invited_vendor.expires_at > Time.current}"
      end
      
      unless @invited_vendor.present? && @invited_vendor.expires_at > Time.current
        Rails.logger.error "Invalid or expired invite token: #{params[:token]}"
        redirect_to new_vendor_session_path, alert: "Invalid or expired invite token"
      end
    else
      # No token provided - redirect to login
      Rails.logger.error "No token provided for vendor registration"
      redirect_to new_vendor_session_path, alert: "You need a valid invitation link to register as a vendor"
    end
  end
end