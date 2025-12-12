class Admin::DiscountsController < ApplicationController
  layout "admin"
  before_action :authenticate_admin!
  before_action :set_discount, only: [:edit, :update, :destroy]

  def index
    @discounts = Discount.includes(:vendor).order(created_at: :desc)

    # Filter by vendor if provided
    if params[:vendor_id].present?
      @discounts = @discounts.where(vendor_id: params[:vendor_id])
    end

    # Filter by category if provided
    if params[:category].present?
      @discounts = @discounts.where(category: params[:category])
    end

    # Filter by active status
    if params[:active].present?
      @discounts = @discounts.where(active: params[:active])
    end
  end

  def new
    @discount = Discount.new
    @vendors = Vendor.active.order(:company_name)
    @categories = Car.distinct.pluck(:category).compact.sort
  end

  def create
    @discount = Discount.new(discount_params)

    if @discount.save
      redirect_to admin_discounts_path, notice: 'Discount was successfully created.'
    else
      @vendors = Vendor.active.order(:company_name)
      @categories = @discount.vendor_id.present? ? get_vendor_categories(@discount.vendor_id) : Car.distinct.pluck(:category).compact.sort
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @vendors = Vendor.active.order(:company_name)
    @categories = @discount.vendor_id.present? ? get_vendor_categories(@discount.vendor_id) : Car.distinct.pluck(:category).compact.sort
  end

  def update
    if @discount.update(discount_params)
      redirect_to admin_discounts_path, notice: 'Discount was successfully updated.'
    else
      @vendors = Vendor.active.order(:company_name)
      @categories = @discount.vendor_id.present? ? get_vendor_categories(@discount.vendor_id) : Car.distinct.pluck(:category).compact.sort
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @discount.destroy
    redirect_to admin_discounts_path, notice: 'Discount was successfully deleted.'
  end

  # AJAX endpoint to get categories for a vendor
  def get_categories
    vendor_id = params[:vendor_id]
    categories = get_vendor_categories(vendor_id)

    render json: { categories: categories }
  end

  private

  def set_discount
    @discount = Discount.find(params[:id])
  end

  def discount_params
    params.require(:discount).permit(:vendor_id, :discount_percentage, :active, category: [])
  end

  def get_vendor_categories(vendor_id)
    return [] if vendor_id.blank?

    Car.where(vendor_id: vendor_id)
       .distinct
       .pluck(:category)
       .compact
       .sort
  end
end
