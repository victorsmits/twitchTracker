FROM ruby:3.3.0-slim-bullseye AS tracker-app-dev

ARG bundle_without
ARG rails_env

ENV BUNDLE_WITHOUT ${bundle_without}
ENV RAILS_ENV ${rails_env}
ENV RACK_ENV ${rails_env}

RUN apt-get update -q && \
    apt-get install -q -y --no-install-recommends \
    shared-mime-info libcurl4 gnupg wget locales less git build-essential libpq-dev make && \
    rm -rf /var/lib/apt/lists/*

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN echo "deb http://apt.postgresql.org/pub/repos/apt buster-pgdg main" > \
    /etc/apt/sources.list.d/pgdg.list && \
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    apt-get update -q && \
    apt-get install -q -y --no-install-recommends postgresql-client-12 libpq-dev && \
    rm -rf /var/lib/apt/lists/*

RUN gem install bundler:2.2.32

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN bundle install --jobs=3 --retry=3

RUN mkdir -p /app/tmp/pids/

EXPOSE 3666

ENTRYPOINT ["./dev-entrypoint.sh"]
