class Document < ApplicationRecord
  belongs_to :user
  has_many_attached :images

  DOC_FIELDS = {
    'passport_photo' => ['Passport Photo', 'passport'],
    'utility_bill' => ['Utility Bill', 'utility_bill'],
    'license_photo' => ['License Photo', 'license'],
    'selfie_with_license' => ['Selfie with License', 'selfie']
  }.freeze

  before_create :set_pending_status

  def self.doc_info_for_field(field)
    DOC_FIELDS[field]
  end

  private

  def set_pending_status
    self.status = 'pending'
  end
end
