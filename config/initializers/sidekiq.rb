# frozen_string_literal: true

require 'sidekiq/web'
require 'sidekiq-scheduler'
require 'sidekiq-scheduler/web'


Sidekiq.configure_server do |config|
  config.redis = {
    size: 30,
    url: Figaro.env.redis_url,
    driver: :ruby,
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE },
    network_timeout: 30,
    pool_timeout: 30
  }

  config.on(:startup) do

    schedule_file = "config/schedule.yml"

    if File.exist?(schedule_file)
      Sidekiq.schedule = YAML.load_file(schedule_file)

      SidekiqScheduler::Scheduler.instance.reload_schedule!
    end
  end

end

Sidekiq.configure_client do |config|
  config.redis = {
    size: 30,
    url: Figaro.env.redis_url,
    driver: :ruby,
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE },
    network_timeout: 30,
    pool_timeout: 30
  }
end
