# frozen_string_literal: true

require 'sidekiq/web'

Sidekiq.configure_server do |config|
  config.redis = {
    size: 30,
    url: Figaro.env.redis_url,
    driver: :ruby,
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE },
    network_timeout: 30,
    pool_timeout: 30
  }
end

Sidekiq.configure_client do |config|
  config.redis = {
    size: 30,
    url: Figaro.env.redis_url,
    driver: :ruby,
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE },
    network_timeout: 30,
    pool_timeout: 30
  }end
