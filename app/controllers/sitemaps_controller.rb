class SitemapsController < ApplicationController
  # This controller serves the sitemap from S3 to bypass public access restrictions
  # and ephemeral filesystem issues on Heroku.

  def show
    begin
      s3 = Aws::S3::Resource.new(region: "us-east-1")
      bucket = s3.bucket("wheels-on-rent-app")
      obj = bucket.object("sitemap.xml.gz")

      if obj.exists?
        # Redirect to a presigned URL (valid for 1 hour)
        # This allows search engines to download the private file using our credentials
        redirect_to obj.presigned_url(:get, expires_in: 3600), allow_other_host: true
      else
        Rails.logger.error "[SitemapsController] Sitemap file missing on S3 bucket 'wheels-on-rent-app'"
        render plain: "Sitemap not found", status: :not_found
      end
    rescue => e
      Rails.logger.error "[SitemapsController] Error: #{e.message}"
      render plain: "Error accessing sitemap", status: :internal_server_error
    end
  end
end
