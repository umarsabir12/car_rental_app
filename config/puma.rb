# This configuration file will be evaluated by Puma. The top-level methods that
# are invoked here are part of Puma's configuration DSL. For more information
# about methods provided by the DSL, see https://puma.io/puma/Puma/DSL.html.

# Puma starts a configurable number of processes (workers) and each process
# serves each request in a thread from an internal thread pool.
#
# The ideal number of threads per worker depends both on how much time the
# application spends waiting for IO operations and on how much you wish to
# to prioritize throughput over latency.
#
# As a rule of thumb, increasing the number of threads will increase how much
# traffic a given process can handle (throughput), but due to CRuby's
# Global VM Lock (GVL) it has diminishing returns and will degrade the
# response time (latency) of the application.
#
# The default is set to 3 threads as it's deemed a decent compromise between
# throughput and latency for the average Rails application.
#
# Any libraries that use a connection pool or another resource pool should
# be configured to provide at least as many connections as the number of
# threads. This includes Active Record's `pool` parameter in `database.yml`.
# Memory-optimized configuration for Heroku Basic dyno (512 MB)
# Reduce threads to minimize memory footprint
threads_count = ENV.fetch("RAILS_MAX_THREADS", 2)
threads threads_count, threads_count

# Specifies the `port` that Puma will listen on to receive requests; default is 3000.
port ENV.fetch("PORT", 3000)

# Specifies the `environment` that Puma will run in.
environment ENV.fetch("RAILS_ENV") { "development" }

# Allow puma to be restarted by `bin/rails restart` command.
plugin :tmp_restart

# Only use a pidfile when requested
pidfile ENV["PIDFILE"] if ENV["PIDFILE"]

# Memory management for production
if ENV["RAILS_ENV"] == "production"
  # Preload app for better memory efficiency
  preload_app!

  # Before forking, disconnect database connections
  before_fork do
    ActiveRecord::Base.connection_pool.disconnect! if defined?(ActiveRecord)
  end

  # After forking, reconnect to database
  on_worker_boot do
    ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
  end

  # Reduce worker killer thresholds for memory management
  # Restart workers if they exceed memory limits
  if ENV["WEB_CONCURRENCY"].to_i <= 1
    # For single worker (Basic dyno), set conservative memory limits
    before_fork do
      require "puma_worker_killer"

      PumaWorkerKiller.config do |config|
        config.ram = 512 # MB - match dyno size
        config.frequency = 10 # seconds - check every 10 seconds
        config.percent_usage = 0.85 # restart at 85% usage (435 MB)
        config.rolling_restart_frequency = 12 * 3600 # restart every 12 hours
      end

      PumaWorkerKiller.start
    end
  end
end
