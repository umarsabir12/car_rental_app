class Admin::CarDocumentsController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_car_document

  def show
  end

  def approve
    @car_document.update(document_status: :approved)
    
    # Log activity for car document approval
    Activity.log_activity(
      vendor: @car_document.car.vendor,
      subject: @car_document,
      action: 'car_document_approved',
      description: "Admin approved mulkiya document for #{@car_document.car.full_name}",
      metadata: { 
        car_id: @car_document.car.id,
        car_name: @car_document.car.full_name,
        admin_action: 'approved'
      }
    )
    
    redirect_back fallback_location: admin_dashboard_index_path, notice: 'Car document approved.'
  end

  def reject
    @car_document.update(document_status: :rejected)
    
    # Log activity for car document rejection
    Activity.log_activity(
      vendor: @car_document.car.vendor,
      subject: @car_document,
      action: 'car_document_rejected',
      description: "Admin rejected mulkiya document for #{@car_document.car.full_name}",
      metadata: { 
        car_id: @car_document.car.id,
        car_name: @car_document.car.full_name,
        admin_action: 'rejected'
      }
    )
    
    redirect_back fallback_location: admin_dashboard_index_path, notice: 'Car document rejected.'
  end

  private
    def set_car_document
      @car_document = CarDocument.find(params[:id])
    end
end


