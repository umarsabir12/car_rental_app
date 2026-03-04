require "puma_worker_killer" if ENV["RAILS_ENV"] == "production"

# Puma configuration for Heroku Standard-1X dyno (512MB)
# 1 worker × 2 threads = safe memory footprint

# Number of threads per worker
# Keep at 2 for 512MB dynos — each thread holds an AR connection
threads_count = ENV.fetch("RAILS_MAX_THREADS", 2)
threads threads_count, threads_count

# Port to listen on
port ENV.fetch("PORT", 3000)

# Environment
environment ENV.fetch("RAILS_ENV", "development")

# Allow puma to be restarted by `bin/rails restart`
plugin :tmp_restart

# Only use a pidfile when requested
pidfile ENV["PIDFILE"] if ENV["PIDFILE"]

# Explicitly set 1 worker on 512MB dyno
# Each worker costs ~150MB — 1 worker keeps you safely under the limit
workers ENV.fetch("WEB_CONCURRENCY", 1)

# Production-only config
if ENV["RAILS_ENV"] == "production"
  # Preload app before forking workers — reduces per-worker memory via copy-on-write
  preload_app!

  before_fork do
    ActiveRecord::Base.connection_pool.disconnect! if defined?(ActiveRecord)

    # PumaWorkerKiller - Restart workers when they exceed a memory limit
    # This prevents indefinite memory growth that leads to R14 errors
    PumaWorkerKiller.config do |config|
      config.ram           = 400 # mb (leaving safe overhead for 512MB dyno)
      config.frequency     = 30  # seconds
      config.percent_usage = 0.95
      config.rolling_restart_frequency = 12 * 3600 # 12 hours
      config.reaper_status_logs = true # logging helps diagnose if restarts are happening
    end
    PumaWorkerKiller.start
  end

  # Re-establish DB connections after each worker boots
  on_worker_boot do
    ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
  end
end
