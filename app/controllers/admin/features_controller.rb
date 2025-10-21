class Admin::FeaturesController < ApplicationController
  layout "admin"
  before_action :authenticate_admin!
  before_action :set_feature, only: [:edit, :update, :destroy]
  
  def index
    @common_features = Feature.where(common: true).order(:name)
    @premium_features = Feature.where(common: false).order(:name)
    @feature = Feature.new
  end

  def create
    @feature = Feature.new(feature_params)
    
    if @feature.save
      redirect_to admin_features_path, notice: 'Feature was successfully created.'
    else
      @common_features = Feature.where(common: true).order(:name)
      @premium_features = Feature.where(common: false).order(:name)
      render :index, status: :unprocessable_entity
    end
  end

  def edit
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to admin_features_path }
    end
  end

  def update
    if @feature.update(feature_params)
      redirect_to admin_features_path, notice: 'Feature was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @feature.destroy
    redirect_to admin_features_path, notice: 'Feature was successfully deleted.'
  end

  private

  def set_feature
    @feature = Feature.find(params[:id])
  end

  def feature_params
    params.require(:feature).permit(:name, :common)
  end
end