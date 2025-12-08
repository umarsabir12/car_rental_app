# Enable Rack::Deflater for gzip compression
Rails.application.config.middleware.insert_before ActionDispatch::Static, Rack::Deflater
