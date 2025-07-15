class DocumentsController < ApplicationController
  before_action :authenticate_user!

  def create
    uploaded_field = nil
    Document::DOC_FIELDS.keys.each do |field|
      if params[field].present?
        uploaded_field = field
        doc_name, doc_type = Document.doc_info_for_field(field)
        doc = current_user.documents.new(doc_name: doc_name, document_type: doc_type)
        doc.images.attach(params[field])
        if doc.save
          redirect_to user_home_path, notice: "#{doc_name} uploaded successfully."
        else
          redirect_to user_home_path, alert: "Failed to upload #{doc_name}."
        end
        return
      end
    end
    redirect_to user_home_path, alert: "No document selected."
  end

  private

  def document_params
    params.require(:document).permit(:doc_name, :document_type, :status, :reason, images: [])
  end
end
