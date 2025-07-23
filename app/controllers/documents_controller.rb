class DocumentsController < ApplicationController
  before_action :authenticate_user!

  def create
    doc = current_user.documents.find_by(id: params[:id])
    if doc && params[:images].present?
      doc.images.attach(params[:images].reject(&:blank?))
      doc.status = 'pending'
      if doc.save
        redirect_to user_home_path, notice: "#{doc.doc_name} uploaded successfully and is now pending review."
      else
        redirect_to user_home_path, alert: "Failed to upload #{doc.doc_name}."
      end
    else
      redirect_to user_home_path, alert: "Document not found or no image selected."
    end
  end

  private

  def document_params
    params.require(:document).permit(:doc_name, :document_type, :status, :reason, images: [])
  end
end
