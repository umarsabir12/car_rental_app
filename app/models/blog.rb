class Blog < ApplicationRecord
  has_one_attached :featured_image, dependent: :purge_later

  validates :title, :content, :category, :author_name, presence: true
  
  scope :published, -> { where('published_at <= ?', Time.current) }

  before_save :generate_slug

  def to_param
    slug
  end

  private

  def generate_slug
    self.slug = title.parameterize if title.present?
  end
end
