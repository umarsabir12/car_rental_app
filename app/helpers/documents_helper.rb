module DocumentsHelper
  # Determine the file type based on content-type
  def get_file_type(attachment)
    content_type = attachment.blob.content_type
    
    case content_type
    when 'application/pdf'
      'pdf'
    when 'application/msword', 
         'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
         'application/vnd.ms-word.document.macroEnabled.12'
      'word'
    when /^image/
      'image'
    else
      'other'
    end
  end

  # Get appropriate icon class for file type
  def file_icon_class(attachment)
    case get_file_type(attachment)
    when 'pdf'
      'fas fa-file-pdf text-red-600'
    when 'word'
      'fas fa-file-word text-blue-600'
    when 'image'
      'fas fa-image text-green-600'
    else
      'fas fa-file text-gray-600'
    end
  end

  # Get file name from attachment
  def attachment_filename(attachment)
    attachment.blob.filename.to_s
  end
end