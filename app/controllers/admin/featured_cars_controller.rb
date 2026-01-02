class Admin::FeaturedCarsController < ApplicationController
  layout "admin"
  before_action :authenticate_admin!

  def index
    # Fetch all cars, ordered by featured status (featured first) then by ID
    @cars = Car.order(featured: :desc, id: :desc)

    # Vendor Filter
    if params[:vendor_id].present?
      @cars = @cars.where(vendor_id: params[:vendor_id])
    end

    # Simple search/filter
    if params[:query].present?
      q = params[:query].downcase
      @cars = @cars.where("lower(brand) LIKE ? OR lower(model) LIKE ?", "%#{q}%", "%#{q}%")
    end

    # Pagination could be added here if needed
    @pagy, @cars = pagy(@cars, items: 20) if defined?(Pagy)
  end

  def update
    @car = Car.friendly.find(params[:id])

    @car.featured = params.dig(:car, :featured)
    if @car.save(validate: false)
      respond_to do |format|
        format.json { render json: { success: true, featured: @car.featured } }
        format.html { redirect_to admin_featured_cars_path, notice: "Car featured status updated." }
      end
    else
      respond_to do |format|
        format.json { render json: { success: false, errors: @car.errors.full_messages }, status: :unprocessable_entity }
        format.html { redirect_to admin_featured_cars_path, alert: "Failed to update status." }
      end
    end
  end
end
