SitemapGenerator::Sitemap.default_host = "https://www.wheelsonrent.ae"
SitemapGenerator::Sitemap.compress = true

# Store the sitemap on S3 so it persists across Heroku dyno restarts and deploys.
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
  # DEBUG: Adding explicit timestamp to root path to verify file is fresh
  add root_path, priority: 1.0, changefreq: "daily", lastmod: Time.now
  
  add cars_path, priority: 0.8, changefreq: "daily"

  # Individual car pages — using priority 0.85 to distinguish from old 0.5 versions
  Car.find_each do |car|
    add car_path(car),
        lastmod:     car.updated_at,
        changefreq:  "daily",
        priority:    0.85
  end

  # Blog listing page
  add blogs_path, priority: 0.7, changefreq: "daily"

  # Individual blog posts (published only)
  Blog.published.find_each do |blog|
    add blog_path(blog),
        lastmod:     blog.updated_at,
        changefreq:  "weekly",
        priority:    0.7
  end

  # Add car category pages (e.g., /cars/suv, /cars/luxury)
  AppConstants::CAR_CATEGORIES.each do |category|
    add cars_by_category_path(category: category[0].parameterize), priority: 0.75, changefreq: "daily"
  end

  # Static pages
  add "/list-your-car-rental-marketplace",     priority: 0.6
end
