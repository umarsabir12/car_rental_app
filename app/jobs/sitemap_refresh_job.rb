class SitemapRefreshJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "[SitemapRefreshJob] Car (approved/available) count: #{Car.with_approved_mulkiya.available.count}"
    Rails.logger.info "[SitemapRefreshJob] Starting sitemap refresh (verbose)..."

    # Check S3 credentials presence
    if ENV["AWS_ACCESS_KEY_ID"].blank? || ENV["AWS_SECRET_ACCESS_KEY"].blank?
      Rails.logger.error "[SitemapRefreshJob] CRITICAL: AWS Credentials missing in ENV!"
    end

    SitemapGenerator::Interpreter.run(verbose: true)

    Rails.logger.info "[SitemapRefreshJob] Sitemap refresh completed successfully."
  rescue => e
    Rails.logger.error "[SitemapRefreshJob] Failed: #{e.class} — #{e.message}"
    Sentry.capture_exception(e) if defined?(Sentry)
    raise # re-raise so Heroku Scheduler logs the failure
  end
end
