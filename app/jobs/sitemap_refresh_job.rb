class SitemapRefreshJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "[SitemapRefreshJob] Car count: #{Car.count}"
    Rails.logger.info "[SitemapRefreshJob] Published Blog count: #{Blog.published.count}"
    Rails.logger.info "[SitemapRefreshJob] Starting sitemap refresh..."

    SitemapGenerator::Interpreter.run(verbose: true)

    Rails.logger.info "[SitemapRefreshJob] Sitemap refresh completed successfully."
  rescue => e
    Rails.logger.error "[SitemapRefreshJob] Failed: #{e.class} — #{e.message}"
    Sentry.capture_exception(e) if defined?(Sentry)
    raise # re-raise so Heroku Scheduler logs the failure
  end
end
