class Vendors::RegistrationsController <  Devise::RegistrationsController
  before_action :check_invite_token, only: [:new]

  def new
    @vendor = Vendor.new(email: @invited_vendor.email, first_name: @invited_vendor.first_name, last_name: @invited_vendor.last_name) if @invited_vendor.present?
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
      redirect_to vendors_profile_path, notice: "Vendor created successfully"
    else
      render :new, alert: "Vendor creation failed"
    end
  end

  private

  def vendor_params
    params.require(:vendor).permit(:email, :first_name, :last_name, :password, :password_confirmation, :company_name, :invite_token)
  end

  def check_invite_token
    if params[:token].present?
      @invited_vendor = InvitedVendor.find_by(invite_token: params[:token])
      unless @invited_vendor.present? && @invited_vendor.expires_at > Time.current
        redirect_to new_vendor_session_path, alert: "Invalid or expired invite token"
      end
    end
  end
end