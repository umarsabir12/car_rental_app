class Users::SessionsController < Devise::SessionsController

    def new
        super do
            @car_id = params[:car_id]
            @start_date = params[:start_date]
            @end_date = params[:end_date]
        end
    end

    def create
     super do |current_user|
        if current_user.persisted? && params[:car_id].present? && params[:start_date].present? && params[:end_date].present?
          # Create booking for the logged in user
          booking = Booking.create!(
            user_id: current_user.id,
            car_id: params[:car_id],
            start_date: params[:start_date],
            end_date: params[:end_date],
            payment_processed: false
          )
          # Redirect to payment page
          redirect_to  user_home_path and return
        end
     end
    end

end
