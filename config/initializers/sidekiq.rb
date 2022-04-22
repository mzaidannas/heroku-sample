Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch("REDIS_URL") { "redis://localhost:6379/0" } }

  # to guarantee messages are delivered with 5 seconds, default is 15
  config.average_scheduled_poll_interval = 5

  Sidekiq.options[:concurrency] = ENV['SIDEKIQ_CONCURRENCY'].to_i if ENV['SIDEKIQ_CONCURRENCY']
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch("REDIS_URL") { "redis://localhost:6379/0" } }
end
