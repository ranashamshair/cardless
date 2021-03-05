require "sidekiq/web"
require 'sidekiq/cron/web'
require 'sidekiq-status'
require 'sidekiq-status/web'
# require 'autoscaler/sidekiq'
# require 'autoscaler/heroku_platform_scaler'



Sidekiq.configure_server do |config|
	schedule_file = "config/schedule.yml"

	if File.exist?(schedule_file) && Sidekiq.server?
	  Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
	end
  	config.redis = { url: ENV['REDIS_URL'] || 'redis://localhost:6379/1' }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDIS_URL'] || 'redis://localhost:6379/1' }
end
