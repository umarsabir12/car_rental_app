class Admin::DocumentsController < ApplicationController
  before_action :authenticate_admin!
  layout "admin"
  before_action :load_resource

  def approve
    if @is_car_document
      @document.update(document_status: :approved)
    else
      @document.update(status: 'approved', reason: nil)
    end
    redirect_to admin_dashboard_index_path
  end

  def reject
    if @is_car_document
      @document.update(document_status: :rejected)
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
    else
      @user = @document.user
    end
  end

  private
    def load_resource
      if params[:type].to_s == 'car_document'
        @document = CarDocument.find(params[:id])
        @is_car_document = true
      else
        @document = Document.find(params[:id])
        @is_car_document = false
      end
    end
end 