#!/bin/bash

# echo "Creating log folder"
mkdir -p $APP_WORKDIR/log

###########
# certbot #
###########

echo "------------- installing certbot -----------"

add-apt-repository ppa:certbot/certbot -y
apt-get update
apt-get install python-certbot-apache -y --no-install-recommends

#Copy in certbot config
cp $APP_WORKDIR/docker/cli.ini /etc/letsencrypt/cli.ini
#make dir that will be used for challenges (if you must change this look at hullsync.conf too)
mkdir -p /var/www/acme-docroot/.well-known/acme-challenge

##########
# apache #
##########

#put server name in apache conf
sed -i "s/#SERVER_NAME#/$HHC_SERVER_NAME/" /etc/apache2/sites-available/hullsync.conf
sed -i "s/#SERVER_NAME#/$HHC_SERVER_NAME/" /etc/apache2/sites-available/hullsync_ssl.conf

echo "--------- Starting Apache -----------"
service apache2 start

echo "-------------- Getting cert(s) -----------"

# We'll register each time as certs are not stored on a persistent volume
certbot register
certbot certonly -n --cert-name base -d $HHC_SERVER_NAME

# copy autorenewal script. Dest directory only exists after the first cert is in place
cp $APP_WORKDIR/docker/00_apache2 /etc/letsencrypt/renewal-hooks/deploy/

echo "--------- Restarting Apache with ssl ---------"
a2ensite hullsync_ssl
service apache2 reload
service apache2 restart

#########
# Rails #
#########

if [ "$RAILS_ENV" = "production" ]; then
    # Verify all the production gems are installed
    bundle check
    rake assets:precompile
else
    # install any missing development gems (as we can tweak the development container without rebuilding it)
    bundle check || bundle install --without production
fi

echo "--------- Running pending migrations ---------"
bundle exec rake db:migrate

echo "--------- Starting Blacklight in $RAILS_ENV mode ---------"
rm -f /tmp/"$APP_KEY".pid
bundle exec rails server -p "$RAILS_PORT" -b '0.0.0.0' --pid /tmp/"$APP_KEY".pid
