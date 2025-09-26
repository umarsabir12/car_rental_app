class Admin::CarDocumentsController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_car_document

  def show
  end

  def approve
    @car_document.update(document_status: :approved)
    redirect_back fallback_location: admin_dashboard_index_path, notice: 'Car document approved.'
  end

  def reject
    @car_document.update(document_status: :rejected)
    redirect_back fallback_location: admin_dashboard_index_path, notice: 'Car document rejected.'
  end

  private
    def set_car_document
      @car_document = CarDocument.find(params[:id])
    end
end


