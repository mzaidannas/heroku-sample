release: bundle exec rake db:migrate
web: bundle exec puma -C config/puma.rb -p $PORT
worker: bundle exec sidekiq -C config/sidekiq.yml
worker_second: bundle exec sidekiq