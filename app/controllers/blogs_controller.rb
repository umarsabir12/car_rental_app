class BlogsController < ApplicationController
  before_action :set_blog, only: [:show]

  def index
    @blogs = Blog.published.order(published_at: :desc).all
  end

  def show
    if @blog.reference_images.attached?
      table_image_url = url_for(@blog.reference_images[0])
      @blog.content = @blog.content.gsub('{{PRICE_TABLE_IMAGE}}', table_image_url)
    end
  end

  private

  def set_blog
    @blog = Blog.find_by!(slug: params[:slug])
    redirect_to blogs_path, alert: 'Blog not found' if @blog.blank?
  end
end