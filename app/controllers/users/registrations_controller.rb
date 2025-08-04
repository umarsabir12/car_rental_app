class Users::RegistrationsController <  Devise::RegistrationsController
  before_action :configure_permitted_parameters, if: :devise_controller?
  
  def new
    super do
      @car_id = params[:car_id]
      @start_date = params[:start_date]
      @end_date = params[:end_date]
    end
  end
  
  def create
    super do |user|
      if user.persisted? && params[:car_id].present? && params[:start_date].present? && params[:end_date].present?
        booking = Booking.create!(
          user_id: user.id,
          car_id: params[:car_id],
          start_date: params[:start_date],
          end_date: params[:end_date],
          payment_processed: false,
          status: 'pending'
        )
        sign_in(user) unless user_signed_in?
        redirect_to user_home_path and return
      end
    end
  end
  
  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :first_name, :last_name, :phone, :home_address, :terms_accepted,
      :card_number, :card_expiry, :card_cvc, :nationality
    ])
    devise_parameter_sanitizer.permit(:account_update, keys: [
      :first_name, :last_name, :phone, :home_address, :terms_accepted,
      :card_number, :card_expiry, :card_cvc, :nationality
    ])
  end
end
