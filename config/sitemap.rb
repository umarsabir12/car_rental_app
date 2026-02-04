SitemapGenerator::Sitemap.default_host = "https://www.wheelsonrent.ae"
SitemapGenerator::Sitemap.compress = true
SitemapGenerator::Sitemap.search_engines = {}

SitemapGenerator::Sitemap.create do
  add root_path, priority: 1.0, changefreq: "daily"

  add cars_path, priority: 0.8, changefreq: "daily"
  Car.find_each do |car|
    add car_path(car),
        lastmod: car.updated_at,
        changefreq: "weekly",
        priority: 0.8
  end

  add blogs_path, priority: 0.7, changefreq: "weekly"
  Blog.published.find_each do |blog|
    add blog_path(blog),
        lastmod: blog.updated_at,
        changefreq: "weekly",
        priority: 0.7
  end

  add "/terms_of_use", priority: 0.4
  add "/list-your-car-rental-marketplace", priority: 0.6
end
