class Admin::FeaturesController < ApplicationController
  layout "admin"
  before_action :authenticate_admin!
  before_action :set_feature, only: [ :edit, :update, :destroy ]

  def index
    @common_features = Feature.where(common: true).order(:name)
    @premium_features = Feature.where(common: false).order(:name)
    @feature = Feature.new
  end

    respond_to do |format|
      if @feature.save
        format.html { redirect_to admin_features_path, notice: "Feature was successfully created." }
      else
        @common_features = Feature.where(common: true).order(:name)
        @premium_features = Feature.where(common: false).order(:name)
        flash.now[:alert] = "Error: #{@feature.errors.full_messages.to_sentence}"
        format.html { render :index, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("form-errors", partial: "shared/form_errors", locals: { object: @feature }),
            turbo_stream.replace("flash-container", partial: "shared/flash_messages")
          ]
        end
      end
    end

  def edit
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to admin_features_path }
    end
  end

    respond_to do |format|
      if @feature.update(feature_params)
        format.html { redirect_to admin_features_path, notice: "Feature was successfully updated." }
      else
        flash.now[:alert] = "Error: #{@feature.errors.full_messages.to_sentence}"
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("form-errors", partial: "shared/form_errors", locals: { object: @feature }),
            turbo_stream.replace("flash-container", partial: "shared/flash_messages")
          ]
        end
      end
    end

  def destroy
    @feature.destroy
    redirect_to admin_features_path, notice: "Feature was successfully deleted."
  end

  private

  def set_feature
    @feature = Feature.find(params[:id])
  end

  def feature_params
    params.require(:feature).permit(:name, :common)
  end
end
