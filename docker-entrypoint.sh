#!/bin/bash

# echo "Creating log folder"
mkdir -p $APP_WORKDIR/log

if [ "$RAILS_ENV" = "production" ]; then
    # Verify all the production gems are installed
    bundle check
    rake assets:precompile
else
    # install any missing development gems (as we can tweak the development container without rebuilding it)
    bundle check || bundle install --without production
fi

# echo "--------- Running pending migrations ---------"
bundle exec rake db:migrate

# echo "--------- Starting Blacklight in $RAILS_ENV mode ---------"
rm -f /tmp/"$APP_KEY".pid
bundle exec rails server -p "$RAILS_PORT" -b '0.0.0.0' --pid /tmp/"$APP_KEY".pid
