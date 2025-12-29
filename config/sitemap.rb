# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "https://www.wheelsonrent.ae/"
# Disable search engine pinging as Google deprecated the API
SitemapGenerator::Sitemap.search_engines = {}

SitemapGenerator::Sitemap.create do
  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host
  #
  # Examples:
  #
  # Add '/articles'
  #
  #   add articles_path, :priority => 0.7, :changefreq => 'daily'
  #
  # Add all articles:
  #
  #   Article.find_each do |article|
  #     add article_path(article), :lastmod => article.updated_at
  #   end

  add cars_path, priority: 0.8, changefreq: 'daily'
  Car.find_each do |car|
    add car_path(car), lastmod: car.updated_at
  end

  add blogs_path, priority: 0.7, changefreq: 'weekly'
  Blog.published.find_each do |blog|
    add blog_path(blog), lastmod: blog.updated_at
  end

  add '/terms_of_use'
  add '/list-your-car-rental-marketplace', priority: 0.6
end
