class DocumentsController < ApplicationController
  before_action :authenticate_user!

  def create
    doc = current_user.documents.find_by(id: params[:id])
    if doc
      success, message = DocumentUploadService.upload(doc, params)
      if success
        redirect_to user_home_path, notice: message
      else
        redirect_to user_home_path, alert: message
      end
    else
      redirect_to user_home_path, alert: "Document not found or no image selected."
    end
  end

  private

  def document_params
    params.require(:document).permit(:doc_name, :document_type, :status, :reason, :front_image, :back_image, images: [])
  end
end
