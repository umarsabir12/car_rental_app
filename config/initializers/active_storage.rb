# Active Storage optimization for faster image loading
Rails.application.configure do
  # Enable variant processing on upload for common sizes
  config.active_storage.variant_processor = :vips

  # Preprocess variants to avoid processing on first request
  config.active_storage.preprocess_variants = true

  # Set service URLs to use CDN if available
  if Rails.env.production?
    # Enable direct uploads to S3 to bypass Rails server
    config.active_storage.resolve_model_to_route = :rails_storage_proxy

    # Use public URLs when possible for better caching
    config.active_storage.track_variants = true
  end
end
