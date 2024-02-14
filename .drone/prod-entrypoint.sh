#! /bin/sh

set -e

echo "Running environment: $RAILS_ENV"

# gem install bundler:2.2.27
 bundle check || bundle install

# Remove pre-existing puma/passenger server.pid
[ -f /app/tmp/pids/server.pid ] && rm -f /app/tmp/pids/server.pid

# Run given arguments (rails console, rails server ...)
bundle exec ${@}
