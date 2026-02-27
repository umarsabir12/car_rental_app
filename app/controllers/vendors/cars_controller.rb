class Vendors::CarsController < ApplicationController
  before_action :authenticate_vendor!
  before_action :set_car, only: [ :show, :edit, :update, :destroy, :remove_image ]
  before_action :load_premium_features, only: [ :new, :edit ]

  def index
    @cars = current_vendor.cars.includes(:features)

    if params[:filter] == "with_driver"
      @cars = @cars.where(with_driver: true)
    end
  end

  def show
    @bookings = @car.bookings.includes(:user)
  end

  def new
    @car = current_vendor.cars.build
  end

  def create
    @car = current_vendor.cars.build(car_params.except(:mulkiya, :feature_ids))

    # Validate that at least one image is uploaded
    if params[:car][:images].blank? || params[:car][:images].all?(&:blank?)
      @car.errors.add(:images, "At least one image is required")
      load_premium_features
      render :new
      return
    end

    # Ensure mulkiya is provided
    if params[:car][:mulkiya].blank? && params[:car][:with_driver] != "1" && params[:car][:category] != "Limousine"
      @car.errors.add(:mulkiya, "Mulkiya document is required")
      load_premium_features
      render :new
      return
    end

    # Attach mulkiya before save so validations pass
    if params[:car][:mulkiya].present?
      @car.build_car_document(document_status: :pending)
      @car.car_document.mulkiya.attach(params[:car][:mulkiya])
    end

    if @car.save

      # Assign selected premium features
      if params[:car][:feature_ids].present?
        feature_ids = params[:car][:feature_ids].reject(&:blank?).map(&:to_i)
        @car.feature_ids = (@car.feature_ids + feature_ids).uniq
      end

      redirect_to vendors_car_thank_you_path, notice: "Car was successfully created."
    else
      load_premium_features
      flash.now[:alert] = "Please fix the following errors:\n#{@car.errors.full_messages.join(', ')}"
      render :new
    end
  end

  def edit
    # @premium_features loaded by before_action
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

    # Handle feature associations
    update_car_features if params[:car][:feature_ids].present?

    if @car.update!(car_params.except(:mulkiya, :feature_ids))
      # Attach/replace mulkiya if provided
      if params[:car][:mulkiya].present?
        if @car.car_document.present?
          @car.car_document.mulkiya.purge if @car.car_document.mulkiya.attached?
          @car.car_document.mulkiya.attach(params[:car][:mulkiya])
          @car.car_document.document_status = :pending
          @car.car_document.save!
        else
          car_document = CarDocument.new
          car_document.mulkiya.attach(params[:car][:mulkiya])
          car_document.document_status = :pending
          car_document.car = @car
          car_document.save!
        end
      end

      redirect_to vendors_car_path(@car), notice: "Car was successfully updated."
    else
      load_premium_features
      render :edit
    end
  end

  def destroy
    @car.destroy
    redirect_to vendors_cars_path, notice: "Car was successfully deleted."
  end

  def thank_you
  end

  def remove_image
    # Handle both JSON and form parameters
    image_index = if request.content_type == "application/json"
      JSON.parse(request.body.read)["image_index"].to_i
    else
      params[:image_index].to_i
    end

    Rails.logger.info "Attempting to remove image at index #{image_index} for car #{@car.id}"

    if @car.images[image_index]
      @car.images[image_index].purge
      Rails.logger.info "Successfully removed image at index #{image_index} for car #{@car.id}"
      render json: { success: true, message: "Image removed successfully" }
    else
      Rails.logger.warn "Image not found at index #{image_index} for car #{@car.id}"
      render json: { success: false, message: "Image not found" }, status: :not_found
    end
  rescue => e
    Rails.logger.error "Error removing image: #{e.message}"
    render json: { success: false, message: "Error removing image" }, status: :internal_server_error
  end

  private

  def set_car
    @car = current_vendor.cars.includes(:features).friendly.find(params[:id])
  end

  def load_premium_features
    @premium_features = Feature.where(common: false).order(:name)
  end

  def update_car_features
    # Get selected premium feature IDs (filter out blank values)
    selected_premium_ids = params[:car][:feature_ids].reject(&:blank?).map(&:to_i)

    # Combine common features with selected premium features
    new_feature_ids = (selected_premium_ids).uniq

    # Update the car's features
    @car.feature_ids = new_feature_ids
  end

  def car_params
    params.require(:car).permit(
      :model, :brand, :category, :color, :year, :daily_price, :weekly_price, :monthly_price, :status, :description,
      :transmission, :fuel_type, :seats, :engine_size,
      :air_conditioning, :gps, :sunroof, :bluetooth, :daily_milleage, :weekly_milleage, :monthly_milleage, :featured,
      :main_image_url, :insurance_policy, :additional_mileage_charge, :with_driver, :mulkiya,
      :five_hours_charge, :ten_hours_charge, :luggage_capacity,
      images: [], feature_ids: []
    )
  end
end
