# syntax = docker/dockerfile:1

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version and Gemfile
ARG RUBY_VERSION=3.2.3
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim as base

# Rails app lives here
WORKDIR /rails

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_WITHOUT="development"

# Install packages needed to build gems
RUN apt-get update -q && apt-get upgrade -y && \
    apt-get install -q -y --no-install-recommends \
    ghostscript curl libgmp-dev nodejs wget locales less \
    build-essential git ca-certificates sudo ca-certificates \
    gnupg2 software-properties-common apt-transport-https lsb-release  &&\
    rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc\
    |gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg && \
    echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" \
    |tee  /etc/apt/sources.list.d/pgdg.list && \
    apt-get update -q && \
    apt-get install -q -y --no-install-recommends \
    postgresql-client-13 libpq-dev && \
    rm -rf /var/lib/apt/lists/*

# Throw-away build stage to reduce size of final image
FROM base as build

# Copy application code
COPY Gemfile* ./

# Precompile bootsnap code for faster boot times
RUN bundle install --jobs=3 --retry=3

COPY --from=depedencies $GEM_HOME $GEM_HOME

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Final stage for app image
FROM base

# Copy built artifacts: gems, application
COPY --from=build $GEM_HOME $GEM_HOME
COPY --from=build /rails /rails

# Run and own only the runtime files as a non-root user for security
RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails db storage tmp
USER rails:rails

ENTRYPOINT ["./prod-entrypoint.sh"]

