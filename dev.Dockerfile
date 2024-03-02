FROM --platform=linux/amd64 ruby:3.2.3-slim

ARG github_key
ARG bundle_without
ARG rails_env

ARG UID=1000
ARG GID=$UID

ENV BUNDLE_WITHOUT ${bundle_without}
ENV RAILS_ENV ${rails_env}
ENV RACk_ENV ${rails_env}

RUN apt-get update -q && apt-get upgrade -y && \
    apt-get install -q -y --no-install-recommends --fix-missing \
    ghostscript curl libgmp-dev nodejs wget locales less \
    build-essential git ca-certificates sudo ca-certificates \
    gnupg2 software-properties-common apt-transport-https lsb-release  &&\
    rm -rf /var/lib/apt/lists/*

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc\
    |gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg && \
    echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" \
    |tee  /etc/apt/sources.list.d/pgdg.list && \
    apt-get update -q && \
    apt-get install -q -y --no-install-recommends --fix-missing \
    postgresql-client-13 libpq-dev && \
    rm -rf /var/lib/apt/lists/*


RUN gem install bundler

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN bundle install --jobs=3 --retry=3

ENTRYPOINT ["./dev-entrypoint.sh"]
