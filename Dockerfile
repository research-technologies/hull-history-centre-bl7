FROM ruby:2.6

# Setup environment variables for use at build time only
ARG APP_PRODUCTION
ARG APP_WORKDIR
ARG SECRET_KEY_BASE
ARG RAILS_ENV

# Setup environment variables to pass to the applications
ENV RAILS_ENV="$RAILS_ENV" \
    LANG=C.UTF-8 \
    JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/jre \
    RAILS_LOG_TO_STDOUT=yes_please \
    BUNDLE_JOBS=2 \
    APP_PRODUCTION="$APP_PRODUCTION"/ \
    APP_WORKDIR="$APP_WORKDIR"/
    
ENV SECRET_KEY_BASE=$SECRET_KEY_BASE

# Add backports to apt-get sources
# Install libraries, dependencies, java

RUN echo 'deb http://deb.debian.org/debian jessie-backports main' > /etc/apt/sources.list.d/jessie-backports.list \
    && apt-get update -qq \
    && apt-get install -y --no-install-recommends \
    libpq-dev \
    libxml2-dev libxslt1-dev \
    ufraw \
    bzip2 unzip xz-utils \
    vim \
    git \
    # install open-jdk and ca-certs from jessie-backports
    && apt-get install -t jessie-backports -y --no-install-recommends openjdk-8-jre-headless ca-certificates-java \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && /var/lib/dpkg/info/ca-certificates-java.postinst configure \
    # https://github.com/docker-library/ruby/issues/226
    && curl -sL https://deb.nodesource.com/setup_10.x | bash - && apt-get install -y nodejs

# copy gemfiles to production folder
COPY Gemfile Gemfile.lock $APP_PRODUCTION

# install gems to system - use flags dependent on RAILS_ENV
RUN cd $APP_PRODUCTION && \
    if [ "$RAILS_ENV" = "production" ]; then \
            bundle install --without test:development; \
        else \
            bundle install --without production --no-deployment; \
        fi \
    && mv Gemfile.lock Gemfile.lock.built_by_docker

# copy the application
COPY . $APP_PRODUCTION
COPY docker-entrypoint.sh /bin/docker-entrypoint.sh

# use the just built Gemfile.lock, not the one copied into the container and verify the gems are correctly installed
RUN cd $APP_PRODUCTION \
    && mv Gemfile.lock.built_by_docker Gemfile.lock \
    && bundle check

# generate production assets if production environment
RUN if [ "$RAILS_ENV" = "production" ]; then \
        cd $APP_PRODUCTION \
        && SECRET_KEY_BASE_PRODUCTION=0 bundle exec rake assets:clean assets:precompile; \
    fi

WORKDIR $APP_WORKDIR

RUN chmod +x /bin/docker-entrypoint.sh
