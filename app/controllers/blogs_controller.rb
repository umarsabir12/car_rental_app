class BlogsController < ApplicationController
  before_action :set_blog, only: [:show]

  def index
    @blogs = Blog.published.order(published_at: :desc).all
  end

  def show
  end

  private

  def set_blog
    @blog = Blog.find_by!(slug: params[:slug])
    redirect_to blogs_path, alert: 'Blog not found' if @blog.blank?
  end
end