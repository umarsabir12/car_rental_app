# class AdminProfilesController < ApplicationController
#   layout "admin"
#   before_action :authenticate_admin!

#   def show
#     @admin = current_admin
#   end

#   def edit
#     @admin = current_admin
#   end

#   def update
#     @admin = current_admin
    
#     if params[:admin][:password].blank?
#       # Update without password
#       if @admin.update(profile_params_without_password)
#         redirect_to admin_profile_path, notice: 'Profile updated successfully.'
#       else
#         render :edit, status: :unprocessable_entity
#       end
#     else
#       # Update with password
#       if @admin.update(profile_params_with_password)
#         redirect_to admin_profile_path, notice: 'Profile updated successfully.'
#       else
#         render :edit, status: :unprocessable_entity
#       end
#     end
#   end

#   private

#   def profile_params_without_password
#     params.require(:admin).permit(:first_name, :last_name, :email)
#   end

#   def profile_params_with_password
#     params.require(:admin).permit(:first_name, :last_name, :email, :password, :password_confirmation)
#   end
# end 