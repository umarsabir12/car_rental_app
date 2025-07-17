class Document < ApplicationRecord
  belongs_to :user
  has_many_attached :images
  before_create :set_pending_status

  TOURIST =  ["Home country driving license and IDP", "Passport Copy", "Copy of visa Entry Stamp"]
  RESIDENT = ["A Valid UAE driving license", "Emirates ID front and back", "Passport and Visa copy"]

  DOC_FIELDS = {
    'uae_license' => ['A Valid UAE driving license', 'uae_license'],
    'emirates_id' => ['Emirates ID front and back', 'emirates_id'],
    'passport_visa' => ['Passport and Visa copy', 'passport_visa'],
    'foreign_license_idp' => ['Home country driving license and IDP', 'foreign_license_idp'],
    'visa_entry_stamp' => ['Copy of visa Entry Stamp', 'visa_entry_stamp'],
    'passport_copy' => ['Passport Copy', 'passport_copy']
  }.freeze


  def self.doc_info_for_field(field)
    DOC_FIELDS[field]
  end

  private

  def set_pending_status
    self.status = 'pending'
  end
end
