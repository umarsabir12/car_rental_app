class Document < ApplicationRecord
  belongs_to :user
  has_many_attached :images, dependent: :purge_later
  has_many :activities, as: :subject, dependent: :destroy
  # before_create :set_pending_status

  TOURIST =  ["Home country driving license and IDP", "Passport Copy", "Copy of visa Entry Stamp"]
  RESIDENT = ["A Valid UAE driving license", "Emirates ID front and back"]

  DOC_FIELDS = {
    "uae_license" => ["A Valid UAE driving license", "uae_license"],
    "emirates_id" => ["Emirates ID front and back", "emirates_id"],
    "passport_visa" => ["Passport and Visa copy", "passport_visa"],
    "foreign_license_idp" => ["Home country driving license and IDP", "foreign_license_idp"],
    "visa_entry_stamp" => ["Copy of visa Entry Stamp", "visa_entry_stamp"],
    "passport_copy" => ["Passport Copy", "passport_copy"]
  }.freeze

  # Callbacks to update booking status when document status changes
  after_update :update_user_bookings_status, :log_document_status_change, if: :saved_change_to_status?

  def self.doc_info_for_field(field)
    DOC_FIELDS[field]
  end

  private

  def set_pending_status
    self.status = "pending"
  end

  def update_user_bookings_status
    # Check if all required documents are approved
    if all_documents_approved?
      # Update all pending bookings to confirmed status
      user.bookings.active.where(status: "pending").update_all(status: "confirmed")
    elsif status == "rejected"
      # If any document is rejected, keep bookings as pending
      user.bookings.active.where(status: "confirmed").update_all(status: "pending")
    end
  end

  def all_documents_approved?
    required_docs = user.nationality == "resident" ? RESIDENT : TOURIST
    user_docs = user.documents.where(doc_name: required_docs)

    # Check if all required documents exist and are approved
    user_docs.count == required_docs.count && user_docs.all? { |doc| doc.status == "approved" }
  end

  def log_document_status_change
    Activity.log_activity(
      user: user,
      subject: self,
      action: "document_#{status}",
      description: "#{user.full_name}'s #{doc_name} was #{status}",
      metadata: {
        document_type: doc_name,
        previous_status: status_before_last_save,
        new_status: status
      }
    )
  end
end
