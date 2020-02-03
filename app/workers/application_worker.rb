class ApplicationWorker
    include Sidekiq::Worker

    sidekiq_options retry: 3, queue: :default
end
