class VendorDocument < ApplicationRecord
  belongs_to :vendor
  has_one_attached :trade_license

  validates :trade_license, presence: { message: "is required for vendor" }

  enum document_status: {
    pending: 0,
    approved: 1,
    rejected: 2
  }

  validate :license_content_type, on: :update

  private

  def license_content_type
    return unless trade_license.attached?

    allowed_types = [
      "application/pdf",
      "image/jpeg",
      "image/jpg",
      "image/png",
      "image/webp",
      "image/heic",
      "image/heif",
      "image/heic-sequence",
      "image/heif-sequence"
    ]

    unless allowed_types.include?(trade_license.content_type)
      errors.add(:trade_license, "must be a PDF or an image (JPEG, PNG, WEBP)")
    end
  end
end
