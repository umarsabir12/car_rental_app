class Blog < ApplicationRecord
  has_one_attached :featured_image, dependent: :purge_later
  has_many_attached :reference_images, dependent: :purge_later

  validates :title, :content, :category, :author_name, :slug, presence: true
  validates :slug, uniqueness: true
  validates :slug, format: {
    with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/,
    message: "must be lowercase letters, numbers, and hyphens only (e.g., 'my-blog-post')"
  }
  validate :slug_format_requirements

  scope :published, -> { where("published_at <= ?", Time.current) }

  def to_param
    slug
  end

  private

  def slug_format_requirements
    return if slug.blank?

    errors.add(:slug, "cannot start with a hyphen") if slug.starts_with?("-")
    errors.add(:slug, "cannot end with a hyphen") if slug.ends_with?("-")
    errors.add(:slug, "cannot contain consecutive hyphens") if slug.include?("--")
  end
end
