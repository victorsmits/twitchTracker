# frozen_string_literal: true

# Article for redis connection pool
# https://tejasbubane.github.io/posts/2020-04-22-redis-connection-pool-in-rails/

pool_size = ENV.fetch('redis_connection_pool_size', 10)

REDIS = ConnectionPool.new(size: pool_size) do
  Redis.new(
    url: Figaro.env.redis_url,
    driver: :ruby,
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE },
    network_timeout: 5
  )
end
