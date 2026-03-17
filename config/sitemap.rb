SitemapGenerator::Sitemap.default_host = "https://www.wheelsonrent.ae"
SitemapGenerator::Sitemap.compress = true

# Store the sitemap on S3 so it persists across Heroku dyno restarts and deploys.
# The sitemap will be publicly accessible at /sitemap.xml.gz via the app URL.
SitemapGenerator::Sitemap.adapter = SitemapGenerator::AwsSdkAdapter.new(
  "wheels-on-rent-app",
  aws_access_key_id:     ENV["AWS_ACCESS_KEY_ID"],
  aws_secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
  aws_region:            "us-east-1",
  acl:                   nil # Modern S3 buckets have ACLs disabled (Bucket Owner Enforced)
)

# Serve the sitemap through the app's public URL (not the raw S3 URL)
SitemapGenerator::Sitemap.sitemaps_host = "https://www.wheelsonrent.ae/"

# Sitemap stored at the root of the bucket → s3://wheels-on-rent-app/sitemap.xml.gz
# This matches the URL declared in public/robots.txt

# Ping Google & Bing to re-crawl after each sitemap refresh
SitemapGenerator::Sitemap.search_engines = {
  google: "https://www.google.com/ping?sitemap=%s",
  bing:   "https://www.bing.com/ping?sitemap=%s"
}

SitemapGenerator::Sitemap.create do
  Rails.logger.info "[Sitemap] Starting create block..."
  add root_path, priority: 1.0, changefreq: "daily"
  add cars_path, priority: 0.8, changefreq: "daily"

  car_count = 0
  Car.with_approved_mulkiya.available.find_each do |car|
    begin
      add car_path(car), lastmod: car.updated_at, changefreq: "daily", priority: 0.8
      car_count += 1
    rescue => e
      Rails.logger.error "[Sitemap] Error adding car #{car.id}: #{e.message}"
    end
  end
  Rails.logger.info "[Sitemap] Added #{car_count} cars."

  add blogs_path, priority: 0.7, changefreq: "daily"

  blog_count = 0
  Blog.published.find_each do |blog|
    begin
      add blog_path(blog), lastmod: blog.updated_at, changefreq: "weekly", priority: 0.7
      blog_count += 1
    rescue => e
      Rails.logger.error "[Sitemap] Error adding blog #{blog.id}: #{e.message}"
    end
  end
  Rails.logger.info "[Sitemap] Added #{blog_count} blogs."

  add "/terms_of_use", priority: 0.4
  add "/list-your-car-rental-marketplace", priority: 0.6
  Rails.logger.info "[Sitemap] Creation block finished."
end
