class SitemapRefreshJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "[SitemapRefreshJob] Car (approved/available) count: #{Car.with_approved_mulkiya.available.count}"
    Rails.logger.info "[SitemapRefreshJob] Starting sitemap refresh (verbose)..."

    # Check S3 credentials and connectivity
    if ENV["AWS_ACCESS_KEY_ID"].blank? || ENV["AWS_SECRET_ACCESS_KEY"].blank?
      Rails.logger.error "[SitemapRefreshJob] CRITICAL: AWS Credentials missing in ENV!"
    else
      # Test S3 connectivity by listing objects (checks if bucket exists and is accessible)
      begin
        s3 = Aws::S3::Client.new(region: "us-east-1")
        s3.list_objects_v2(bucket: "wheels-on-rent-app", max_keys: 1)
        Rails.logger.info "[SitemapRefreshJob] S3 connection verified: bucket 'wheels-on-rent-app' is accessible."
      rescue => e
        Rails.logger.error "[SitemapRefreshJob] S3 connection FAILED: #{e.message}"
      end
    end

    SitemapGenerator::Interpreter.run(verbose: true)

    Rails.logger.info "[SitemapRefreshJob] Sitemap refresh completed successfully."
  rescue => e
    Rails.logger.error "[SitemapRefreshJob] Failed: #{e.class} — #{e.message}"
    Sentry.capture_exception(e) if defined?(Sentry)
    raise # re-raise so Heroku Scheduler logs the failure
  end
end
