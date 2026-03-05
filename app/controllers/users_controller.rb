class UsersController < ApplicationController
  before_action :authenticate_user!

  def home
    @user = current_user
    @bookings = @user.bookings.includes(:car)
    if (msg = @user.document_alert_message)
      flash.now[:alert] = msg
    end
  end

  def profile
    @user = current_user
  end

  def bookings
    @bookings = current_user.bookings.includes(:car)
  end

  def show
    @user = current_user
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    respond_to do |format|
      if @user.update(user_params)
        # Log profile update activity
        Activity.log_activity(
          user: @user,
          subject: @user,
          action: "profile_updated",
          description: "#{@user.full_name} updated their profile",
          metadata: {
            updated_fields: user_params.keys,
            nationality: @user.nationality,
            whatsapp_number: @user.whatsapp_number
          },
          request: request
        )
        format.html { redirect_to user_path(@user), notice: "Profile updated successfully." }
      else
        flash.now[:alert] = "Error: #{@user.errors.full_messages.to_sentence}"
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("form-errors", partial: "shared/form_errors", locals: { object: @user }),
            turbo_stream.replace("flash-container", partial: "shared/flash_messages")
          ]
        end
      end
    end
  end

  def update_nationality
    if current_user.update!(nationality: params[:nationality])
      render json: { success: true, nationality: current_user.nationality }
    else
      render json: { success: false, errors: current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(
      :first_name, :last_name, :email, :phone, :home_address,
      :nationality, :terms_accepted, :whatsapp_number
    )
  end
end
