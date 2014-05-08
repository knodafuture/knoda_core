Sidekiq.configure_server do |config|
  config.redis = { :namespace => 'sidekiq-knoda' }
end
