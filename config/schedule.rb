# Use this file to easily define all of your cron jobs.
#
# It's helpful to be aware of what output this script generates.
# Missed it? Run `whenever --help`

# Output log for debugging
set :output, "log/cron.log"

# Run the sitemap refresh job daily at 5:00 AM
every 1.day, at: "5:00 am" do
  runner "SitemapRefreshJob.perform_now"
end
