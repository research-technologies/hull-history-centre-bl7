FROM ruby:2.6

# Setup environment variables for use at build time only
ARG APP_WORKDIR
ARG SECRET_KEY_BASE
ARG RAILS_ENV

# Setup environment variables to pass to the applications
ENV RAILS_ENV="$RAILS_ENV" \
    LANG=C.UTF-8 \
    RAILS_LOG_TO_STDOUT=yes_please \
    BUNDLE_JOBS=2 \
    APP_WORKDIR="$APP_WORKDIR"/
    
ENV SECRET_KEY_BASE=$SECRET_KEY_BASE

# Add backports to apt-get sources
# Install libraries, dependencies, java
RUN apt-get update -qq \
    && apt-get install -y --no-install-recommends \
    libpq-dev \
    libxml2-dev libxslt1-dev \
    bzip2 unzip xz-utils \
    vim tree \
    apache2 \
    software-properties-common \
    git \
    # https://github.com/docker-library/ruby/issues/226
    && curl -sL https://deb.nodesource.com/setup_10.x | bash - && apt-get install -y nodejs

WORKDIR $APP_WORKDIR

## install apache, certs and modules for proxy##
COPY docker/ssl.conf /etc/apache2/conf-available/
RUN a2enconf ssl

COPY docker/hhc.conf /etc/apache2/sites-available/
COPY docker/hhc_ssl.conf /etc/apache2/sites-available/

#SSL will be started after we are up and certbot has done its thang (so just the 80 vhost for now)
RUN a2ensite hhc

RUN a2enmod ssl
RUN a2enmod headers
RUN a2enmod rewrite
RUN a2enmod proxy
RUN a2enmod proxy_balancer
RUN a2enmod proxy_http

# copy gemfiles to production folder
COPY Gemfile Gemfile.lock $APP_WORKDIR

# install gems to system - use flags dependent on RAILS_ENV
RUN if [ "$RAILS_ENV" = "production" ]; then \
            bundle install --without test:development; \
        else \
            bundle install --without production --no-deployment; \
        fi \
    && mv Gemfile.lock Gemfile.lock.built_by_docker

# copy the application
COPY . $APP_WORKDIR

# use the just built Gemfile.lock, not the one copied into the container and verify the gems are correctly installed
RUN mv Gemfile.lock.built_by_docker Gemfile.lock \
    && bundle check

# generate production assets if production environment
RUN if [ "$RAILS_ENV" = "production" ]; then \
        SECRET_KEY_BASE_PRODUCTION=0 bundle exec rake assets:clean assets:precompile; \
    fi

COPY docker-entrypoint.sh /bin/docker-entrypoint.sh
RUN chmod +x /bin/docker-entrypoint.sh
