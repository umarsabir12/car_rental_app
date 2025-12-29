class SitemapRefreshJob < ApplicationJob
  queue_as :default

  def perform
    # Invoke the rake task to refresh the sitemap
    Rails.logger.info "Starting Sitemap Refresh Job..."
    SitemapGenerator::Interpreter.run
    Rails.logger.info "Sitemap Refresh Job Completed."
  end
end
