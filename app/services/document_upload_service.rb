class DocumentUploadService
  # Handles document image uploads for both resident and tourist documents
  # Params:
  # - document: the Document record
  # - params: the params hash from the controller
  # Returns: [success, message]
  def self.upload(document, params)
    case document.doc_name
    when 'Home country driving license and IDP', 'A Valid UAE driving license', 'Emirates ID front and back'
      front = params[:front_image] 
      back = params[:back_image]
      unless front.present? && back.present?
        return [false, 'Both front and back images are required.']
      end
      document.images.attach(front)
      document.images.attach(back)
      document.status = 'pending'
      if document.save
        # Log document upload activity
        Activity.log_activity(
          user: document.user,
          subject: document,
          action: 'document_uploaded',
          description: "#{document.user.full_name} uploaded #{document.doc_name}",
          metadata: { document_type: document.doc_name }
        )
        [true, "#{document.doc_name} uploaded successfully and is now pending review."]
      else
        [false, "Failed to upload #{document.doc_name}."]
      end
    when 'Passport and Visa copy'
      passport = params[:passport_image]
      visa = params[:visa_image]
      unless passport.present? && visa.present?
        return [false, 'Both passport and visa copies are required.']
      end
      debugger
      document.images.attach(passport)
      document.images.attach(visa)
      document.status = 'pending'
      if document.save
        [true, "#{document.doc_name} uploaded successfully and is now pending review."]
      else
        [false, "Failed to upload #{document.doc_name}."]
      end
    else
      if params[:images].present?
        document.images.attach(params[:images].reject(&:blank?))
        document.status = 'pending'
        if document.save
          # Log document upload activity
          Activity.log_activity(
            user: document.user,
            subject: document,
            action: 'document_uploaded',
            description: "#{document.user.full_name} uploaded #{document.doc_name}",
            metadata: { document_type: document.doc_name }
          )
          [true, "#{document.doc_name} uploaded successfully and is now pending review."]
        else
          [false, "Failed to upload #{document.doc_name}."]
        end
      else
        [false, 'Document not found or no image selected.']
      end
    end
  end
end 