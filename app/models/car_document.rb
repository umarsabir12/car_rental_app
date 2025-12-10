class CarDocument < ApplicationRecord
  has_one_attached :mulkiya
  belongs_to :car

  validates :mulkiya, presence: { message: "is required for all cars" }

  enum document_status: {
    pending: 0,
    approved: 1,
    rejected: 2
  }

  validate :mulkiya_presence_on_create, on: :create
  validate :mulkiya_content_type
  before_destroy :purge_attachment

  private

  def purge_attachment
    mulkiya.purge if mulkiya.attached?
  end

  def mulkiya_presence_on_create
    if new_record? && !mulkiya.attached?
      errors.add(:mulkiya, "must be uploaded before creating the car")
    end
  end

  def mulkiya_content_type
    return unless mulkiya.attached?

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

    unless allowed_types.include?(mulkiya.content_type)
      errors.add(:mulkiya, "must be a PDF or an image (JPEG, PNG, WEBP)")
    end
  end
end
