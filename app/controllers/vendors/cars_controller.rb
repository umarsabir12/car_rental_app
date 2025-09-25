class Vendors::CarsController < ApplicationController
  before_action :authenticate_vendor!
  before_action :set_car, only: [:show, :edit, :update, :destroy, :remove_image]

  def index
    @cars = current_vendor.cars
  end

  def show
    @bookings = @car.bookings.includes(:user)
  end

  def new
    @car = current_vendor.cars.build
  end

  def create
    @car = current_vendor.cars.build(car_params)
    
    # Validate that at least one image is uploaded
    if params[:car][:images].blank? || params[:car][:images].all?(&:blank?)
      @car.errors.add(:images, "At least one image is required")
      render :new
      return
    end

    # Ensure mulkiya is provided
    if params[:car][:mulkiya].blank?
      @car.errors.add(:mulkiya, "Mulkiya document is required")
      render :new
      return
    end
    
    # Attach mulkiya before save so validations pass
    @car.mulkiya.attach(params[:car][:mulkiya]) if params[:car][:mulkiya].present?
    
    if @car.save
      redirect_to vendors_car_path(@car), notice: 'Car was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    # Handle image removal
    if params[:remove_image_ids].present?
      params[:remove_image_ids].each do |image_index|
        image_index = image_index.to_i
        if @car.images[image_index]
          @car.images[image_index].purge
        end
      end
    end
    
    # Handle image management - append new images instead of replacing
    if params[:car][:images].present?
      # Filter out blank file inputs
      new_images = params[:car][:images].reject(&:blank?)
      
      if new_images.any?
        # Append new images to existing ones
        @car.images.attach(new_images)
      end
      
      # Remove the images from params to prevent Rails from replacing all images
      params[:car].delete(:images)
    end
    
    if @car.update(car_params)
      # Attach/replace mulkiya if provided
      if params[:car][:mulkiya].present?
        @car.mulkiya.attach(params[:car][:mulkiya])
      end
      redirect_to vendors_car_path(@car), notice: 'Car was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @car.destroy
    redirect_to vendors_cars_path, notice: 'Car was successfully deleted.'
  end

  def remove_image
    # Handle both JSON and form parameters
    image_index = if request.content_type == 'application/json'
      JSON.parse(request.body.read)['image_index'].to_i
    else
      params[:image_index].to_i
    end
    
    Rails.logger.info "Attempting to remove image at index #{image_index} for car #{@car.id}"
    
    if @car.images[image_index]
      @car.images[image_index].purge
      Rails.logger.info "Successfully removed image at index #{image_index} for car #{@car.id}"
      render json: { success: true, message: 'Image removed successfully' }
    else
      Rails.logger.warn "Image not found at index #{image_index} for car #{@car.id}"
      render json: { success: false, message: 'Image not found' }, status: :not_found
    end
  rescue => e
    Rails.logger.error "Error removing image: #{e.message}"
    render json: { success: false, message: 'Error removing image' }, status: :internal_server_error
  end

  private
    def set_car
      @car = current_vendor.cars.find(params[:id])
    end

    def car_params
      params.require(:car).permit(
        :model, :brand, :category, :color, :year, :daily_price, :weekly_price, :monthly_price, :status, :description,
        :transmission, :fuel_type, :seats, :mileage, :engine_size,
        :air_conditioning, :gps, :sunroof, :bluetooth, :daily_milleage, :weekly_milleage, :monthly_milleage, :featured,
        :with_driver, :main_image_url, :mulkiya, :insurance_policy, :additional_mileage_charge, images: []
      )
    end
end 
