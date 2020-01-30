class ApplicationWorker
    self.abstract_class = true

    include Sidekiq::Worker

    sidekiq_options retry: 3, queue: :default
end
