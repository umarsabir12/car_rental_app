if Rails.env.production? && ENV["REDIS_URL"]&.start_with?("rediss://")
  ssl_params = { verify_mode: OpenSSL::SSL::VERIFY_NONE }

  Kredis.configure do |config|
    config.options = { ssl_params: ssl_params }
  end

  ActionCable.server.config.cable = {
    "adapter" => "redis",
    "url" => ENV["REDIS_URL"],
    "channel_prefix" => "car_rental_production",
    "ssl_params" => ssl_params
  }
end
