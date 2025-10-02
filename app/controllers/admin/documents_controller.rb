class Admin::DocumentsController < ApplicationController
  before_action :authenticate_admin!
  layout "admin"
  before_action :load_resource

  def approve
    if @is_car_document || @is_vendor_document
      @document.update(document_status: :approved)
      
      # Log activity for car document approval
      if @is_car_document
        Activity.log_activity(
          vendor: @document.car.vendor,
          subject: @document,
          action: 'car_document_approved',
          description: "Admin approved mulkiya document for #{@document.car.full_name}",
          metadata: { 
            car_id: @document.car.id,
            car_name: @document.car.full_name,
            admin_action: 'approved'
          }
        )
      end
      
      # Log activity for vendor trade license approval
      if @is_vendor_document
        Activity.log_activity(
          vendor: @document.vendor,
          subject: @document,
          action: 'vendor_document_approved',
          description: "Admin approved trade license for #{@document.vendor.company_name}",
          metadata: { 
            vendor_id: @document.vendor.id,
            vendor_name: @document.vendor.company_name,
            admin_action: 'approved'
          }
        )
      end
    else
      @document.update(status: 'approved', reason: nil)
    end
    redirect_to admin_dashboard_index_path
  end

  def reject
    if @is_car_document || @is_vendor_document
      @document.update(document_status: :rejected)
      
      # Log activity for car document rejection
      if @is_car_document
        Activity.log_activity(
          vendor: @document.car.vendor,
          subject: @document,
          action: 'car_document_rejected',
          description: "Admin rejected mulkiya document for #{@document.car.full_name}",
          metadata: { 
            car_id: @document.car.id,
            car_name: @document.car.full_name,
            admin_action: 'rejected'
          }
        )
      end
      
      # Log activity for vendor trade license rejection
      if @is_vendor_document
        Activity.log_activity(
          vendor: @document.vendor,
          subject: @document,
          action: 'vendor_document_rejected',
          description: "Admin rejected trade license for #{@document.vendor.company_name}",
          metadata: { 
            vendor_id: @document.vendor.id,
            vendor_name: @document.vendor.company_name,
            admin_action: 'rejected'
          }
        )
      end
      
      redirect_to admin_dashboard_index_path
    else
      if params[:reason].present?
        @document.update(status: 'rejected', reason: params[:reason])
        redirect_to admin_dashboard_index_path
      else
        flash[:alert] = "Reason Required"
      end
    end
  end

  def show
    if @is_car_document
      @car = @document.car
    elsif @is_vendor_document
      @vendor = @document.vendor
    else
      @user = @document.user
    end
  end

  private
    def load_resource
      if params[:type].to_s == 'car_document'
        @document = CarDocument.find(params[:id])
        @is_car_document = true
      elsif params[:type].to_s == 'trade_license'
        @document = VendorDocument.find(params[:id])
        @is_vendor_document = true
      else
        @document = Document.find(params[:id])
        @is_car_document = false
      end
    end
end 