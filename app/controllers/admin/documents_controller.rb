class Admin::DocumentsController < ApplicationController
  before_action :authenticate_admin!
  layout "admin"

  def approve
    doc = Document.find(params[:id])
    doc.update(status: 'approved', reason: nil)
    redirect_to admin_dashboard_index_path
  end

  def reject
    doc = Document.find(params[:id])
    if params[:reason].present?
      doc.update(status: 'rejected', reason: params[:reason])
      redirect_to admin_dashboard_index_path
    else
        flash[:alert] = "Reason Required"
    end
  end

  def show
    @document = Document.find(params[:id])
    @user = @document.user
  end
end 