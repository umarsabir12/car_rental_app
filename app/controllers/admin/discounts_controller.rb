class Admin::DiscountsController < ApplicationController
  layout "admin"
  before_action :authenticate_admin!
  before_action :set_discount, only: [ :edit, :update, :destroy ]

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
    @categories = (Car.distinct.pluck(:category).compact.reject(&:blank?) + [ "With Driver" ]).uniq.sort
  end

  def create
    @discount = Discount.new(discount_params)

    respond_to do |format|
      if @discount.save
        format.html { redirect_to admin_discounts_path, notice: "Discount was successfully created." }
      else
        @vendors = Vendor.active.order(:company_name)
        @categories = @discount.vendor_id.present? ? get_vendor_categories(@discount.vendor_id) : (Car.distinct.pluck(:category).compact.reject(&:blank?) + [ "With Driver" ]).uniq.sort

        flash.now[:alert] = "Error: #{@discount.errors.full_messages.to_sentence}"
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("form-errors", partial: "shared/form_errors", locals: { object: @discount }),
            turbo_stream.replace("flash-container", partial: "shared/flash_messages")
          ]
        end
      end
    end
  end

  def edit
    @vendors = Vendor.active.order(:company_name)
    @categories = @discount.vendor_id.present? ? get_vendor_categories(@discount.vendor_id) : (Car.distinct.pluck(:category).compact.reject(&:blank?) + [ "With Driver" ]).uniq.sort
  end

  def update
    respond_to do |format|
      if @discount.update(discount_params)
        format.html { redirect_to admin_discounts_path, notice: "Discount was successfully updated." }
      else
        @vendors = Vendor.active.order(:company_name)
        @categories = @discount.vendor_id.present? ? get_vendor_categories(@discount.vendor_id) : (Car.distinct.pluck(:category).compact.reject(&:blank?) + [ "With Driver" ]).uniq.sort

        flash.now[:alert] = "Error: #{@discount.errors.full_messages.to_sentence}"
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("form-errors", partial: "shared/form_errors", locals: { object: @discount }),
            turbo_stream.replace("flash-container", partial: "shared/flash_messages")
          ]
        end
      end
    end
  end

  def destroy
    @discount.destroy
    redirect_to admin_discounts_path, notice: "Discount was successfully deleted."
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
       .reject(&:blank?)
       .push("With Driver")
       .uniq
       .sort
  end
end
