class Admin::AdminsController < ApplicationController
  layout "admin"
  before_action :authenticate_admin!
  before_action :ensure_super_admin!, except: [:index, :show]
  before_action :set_admin, only: [:show, :edit, :update, :destroy]

  def index
    @admins = Admin.all.order(:created_at)
  end

  def show
  end

  def new
    @admin = Admin.new
  end

  def create
    @admin = Admin.new(admin_params)
    
    if @admin.save
      redirect_to admin_admins_path, notice: 'Admin was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @admin.update(admin_params)
      redirect_to admin_admins_path, notice: 'Admin was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @admin == current_admin
      redirect_to admin_admins_path, alert: 'You cannot delete your own account.'
    else
      @admin.destroy
      redirect_to admin_admins_path, notice: 'Admin was successfully deleted.'
    end
  end

  private

  def set_admin
    @admin = Admin.find(params[:id])
  end

  def admin_params
    if params[:admin][:password].blank?
      params.require(:admin).permit(:first_name, :last_name, :email, :role_type)
    else
      params.require(:admin).permit(:first_name, :last_name, :email, :password, :password_confirmation, :role_type)
    end
  end

  def ensure_super_admin!
    unless current_admin.super_admin?
      redirect_to admin_admins_path, alert: 'You do not have permission to perform this action.'
    end
  end
end 