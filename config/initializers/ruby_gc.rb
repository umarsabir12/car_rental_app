# frozen_string_literal: true

# Ruby Garbage Collection tuning for memory-constrained environments
# Optimized for Heroku Basic dyno (512 MB RAM)

if ENV["RAILS_ENV"] == "production"
  # More aggressive GC to keep memory usage lower
  # These settings trade some CPU for lower memory usage

  GC::Profiler.enable

  # RUBY_GC_HEAP_INIT_SLOTS: Initial number of heap slots
  # Lower value = less memory on startup
  ENV["RUBY_GC_HEAP_INIT_SLOTS"] ||= "10000"

  # RUBY_GC_HEAP_FREE_SLOTS: Minimum free slots after GC
  # Lower value = more frequent GC but less memory
  ENV["RUBY_GC_HEAP_FREE_SLOTS"] ||= "1000"

  # RUBY_GC_HEAP_GROWTH_FACTOR: Heap growth multiplier
  # Lower value = slower heap growth = less memory
  ENV["RUBY_GC_HEAP_GROWTH_FACTOR"] ||= "1.1"

  # RUBY_GC_HEAP_GROWTH_MAX_SLOTS: Maximum slots to add at once
  # Lower value = controlled memory growth
  ENV["RUBY_GC_HEAP_GROWTH_MAX_SLOTS"] ||= "10000"

  # RUBY_GC_HEAP_OLDOBJECT_LIMIT_FACTOR: Old object promotion threshold
  # Lower value = more aggressive old gen collection
  ENV["RUBY_GC_HEAP_OLDOBJECT_LIMIT_FACTOR"] ||= "0.9"

  # RUBY_GC_MALLOC_LIMIT: Bytes allocated before GC
  # Lower value = more frequent GC = less memory bloat
  ENV["RUBY_GC_MALLOC_LIMIT"] ||= "16000000" # 16 MB

  # RUBY_GC_MALLOC_LIMIT_MAX: Maximum malloc limit
  ENV["RUBY_GC_MALLOC_LIMIT_MAX"] ||= "32000000" # 32 MB

  # RUBY_GC_MALLOC_LIMIT_GROWTH_FACTOR: Malloc limit growth
  ENV["RUBY_GC_MALLOC_LIMIT_GROWTH_FACTOR"] ||= "1.1"

  # RUBY_GC_OLDMALLOC_LIMIT: Old object malloc threshold
  ENV["RUBY_GC_OLDMALLOC_LIMIT"] ||= "16000000" # 16 MB

  # RUBY_GC_OLDMALLOC_LIMIT_MAX: Maximum old malloc limit
  ENV["RUBY_GC_OLDMALLOC_LIMIT_MAX"] ||= "32000000" # 32 MB

  Rails.logger.info "Ruby GC configured for memory-constrained environment"
  Rails.logger.info "GC Stats: #{GC.stat.inspect}"
end
