class AdminsController < ApplicationController
  layout "admin"
  before_action :authenticate_admin!
  before_action :ensure_super_admin!, only: [:new, :create]

  def index
    @admins = Admin.all
  end

  def new
    @admin = Admin.new
  end

  def create
    @admin = Admin.new(admin_params)
    
    if @admin.save
      redirect_to admins_path, notice: 'Admin created successfully.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @admin = current_admin
  end

  def edit
    @admin = current_admin
  end

  def update
    @admin = current_admin
    
    if params[:admin][:password].blank?
      # Update without password
      if @admin.update(profile_params_without_password)
        redirect_to admins_path, notice: 'Profile updated successfully.'
      else
        render :edit, status: :unprocessable_entity
      end
    else
      # Update with password
      if @admin.update(profile_params_with_password)
        redirect_to admins_path, notice: 'Profile updated successfully.'
      else
        render :edit, status: :unprocessable_entity
      end
    end
  end

  private

  def ensure_super_admin!
    unless current_admin.super_admin?
      redirect_to admins_path, alert: 'You do not have permission to perform this action.'
    end
  end

  def admin_params
    params.require(:admin).permit(:first_name, :last_name, :email, :password, :password_confirmation, :role_type)
  end

  def profile_params_without_password
    params.require(:admin).permit(:first_name, :last_name, :email)
  end

  def profile_params_with_password
    params.require(:admin).permit(:first_name, :last_name, :email, :password, :password_confirmation)
  end
end 