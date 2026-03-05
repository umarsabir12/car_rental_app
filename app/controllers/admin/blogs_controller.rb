class Admin::BlogsController < ApplicationController
  layout "admin"
  before_action :authenticate_admin!

  def index
    @blogs = Blog.order(created_at: :desc)
  end

  def new
    @blog = Blog.new
  end

  def create
    @blog = Blog.new(blog_params)

    if params[:blog][:document].present?
      begin
        file_path = params[:blog][:document].path
        # Convert .docx to HTML using custom service
        html = DocxParserService.new(file_path).convert_to_html
        @blog.content = html
      rescue => e
        flash.now[:alert] = "Error parsing document: #{e.message}"
        render :new and return
      end
    end

    respond_to do |format|
      if @blog.save
        format.html { redirect_to admin_blogs_path, notice: "Blog created successfully." }
      else
        flash.now[:alert] = "Error: #{@blog.errors.full_messages.to_sentence}"
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace('form-errors', partial: 'shared/form_errors', locals: { object: @blog }),
            turbo_stream.replace('flash-container', partial: 'shared/flash_messages')
          ]
        end
      end
    end
  end

  def edit
    @blog = Blog.find_by_slug(params[:id])
  end

  def update
    @blog = Blog.find_by_slug(params[:id])

    if params[:blog][:document].present?
      begin
        file_path = params[:blog][:document].path
        html = DocxParserService.new(file_path).convert_to_html
        @blog.content = html
      rescue => e
        flash.now[:alert] = "Error parsing document: #{e.message}"
        render :edit and return
      end
    end

    # Filter out blank attachment params to preserve existing files if no new ones are uploaded
    filtered_params = blog_params.dup
    if filtered_params[:featured_image].blank?
      filtered_params.delete(:featured_image)
    end

    # Handle reference_images: Append new ones, don't replace existing.
    if filtered_params[:reference_images].present? && !(filtered_params[:reference_images].is_a?(Array) && filtered_params[:reference_images].all?(&:blank?))
      new_images = filtered_params[:reference_images].reject(&:blank?)
      @blog.reference_images.attach(new_images)
    end
    # Always remove from params so simple update doesn't trigger replacement
    filtered_params.delete(:reference_images)

    respond_to do |format|
      if @blog.update(filtered_params)
        format.html { redirect_to admin_blogs_path, notice: "Blog updated successfully." }
      else
        flash.now[:alert] = "Error: #{@blog.errors.full_messages.to_sentence}"
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace('form-errors', partial: 'shared/form_errors', locals: { object: @blog }),
            turbo_stream.replace('flash-container', partial: 'shared/flash_messages')
          ]
        end
      end
    end
  end

  def destroy
    @blog = Blog.find_by_slug(params[:id])
    @blog.destroy
    redirect_to admin_blogs_path, notice: "Blog deleted."
  end

  private

  def blog_params
    params.require(:blog).permit(:title, :slug, :category, :author_name, :meta_title, :meta_description, :published_at, :featured_image, reference_images: [])
  end
end
