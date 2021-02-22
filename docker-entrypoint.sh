#!/bin/bash

# echo "Creating log folder"
mkdir -p $APP_WORKDIR/log

##########
# apache #
##########

#put server name in apache conf
sed -i "s/#SERVER_NAME#/$HHC_SERVER_NAME/" /etc/apache2/sites-available/hhc.conf
sed -i "s/#SERVER_NAME#/$HHC_SERVER_NAME/" /etc/apache2/sites-available/hhc_ssl.conf

if [ -z "$DOCKER_UP_BUILD"  ]; then 

	echo "--------- Starting Apache -----------"
	service apache2 start

        if [ -f /data/pki/$APP_KEY/letsencrypt/live/base/fullchain.pem ]; then

                echo "We should already have a cert so lets not encrypt at this precise moment...."
                mkdir -p /etc/letsencrypt #not sure this step needed anymore...
                cp -r /data/pki/$APP_KEY/letsencrypt/* /etc/letsencrypt/
        else
                echo "-------------## Getting cert(s) ##----------"

                #Copy in certbot config
                cp $APP_WORKDIR/docker/cli.ini /etc/letsencrypt/cli.ini
                #make dir that will be used for challenges (if you must change this look at hullsync.conf too)
                mkdir -p /var/www/acme-docroot/.well-known/acme-challenge

                # We'll register each time as certs are not stored on a persistent volume
		certbot certonly -n --webroot -w /var/www/acme-docroot --cert-name base -d $HHC_SERVER_NAME

                # copy autorenewal script. Dest directory only exists after the first cert is in place
        fi

        cp $APP_WORKDIR/docker/00_apache2 /etc/letsencrypt/renewal-hooks/deploy/

        if [ ! -d /data/pki/$APP_KEY/letsencrypt/live ]; then
            echo "copy the certs for later use"
            mkdir -p /data/pki/$APP_KEY #in case
            cp -rL /etc/letsencrypt /data/pki/$APP_KEY/
        fi


	echo "--------- Restarting Apache with ssl and real cert ---------"
else

        echo "--------- Starting Apache with ssl (ignoring cert domain name for local docker up) ---------"
        mkdir -p /etc/apache2/ssl/certs
        mkdir -p /etc/apache2/ssl/private
        ln -s $APP_WORKDIR/vendor/$GEM_KEY/pki/$SSL_CERT /etc/apache2/ssl/certs/$SSL_CERT
        ln -s $APP_WORKDIR/vendor/$GEM_KEY/pki/$SSL_KEY /etc/apache2/ssl/private/$SSL_KEY
        ln -s $APP_WORKDIR/vendor/$GEM_KEY/pki/$SSL_CA /etc/apache2/ssl/certs/$SSL_CA

        sed -i "s#/etc/letsencrypt/live/base/fullchain.pem#/etc/apache2/ssl/certs/$SSL_CERT#" /etc/apache2/sites-available/hyrax_ssl.conf
        sed -i "s#/etc/letsencrypt/live/base/privkey.pem#/etc/apache2/ssl/private/$SSL_KEY#" /etc/apache2/sites-available/hyrax_ssl.conf

fi

echo "--------- Restarting Apache with ssl ---------"
a2ensite hhc_ssl
service apache2 reload
service apache2 restart

#########
# Rails #
#########

if [ "$RAILS_ENV" = "production" ]; then
    # Verify all the production gems are installed
    bundle check
    bundle exec rake assets:precompile
else
    # install any missing development gems (as we can tweak the development container without rebuilding it)
    bundle check || bundle install --without production
fi

echo "--------- Running pending migrations ---------"
bundle exec rake db:migrate

echo "--------- Starting Blacklight in $RAILS_ENV mode ---------"
rm -f /tmp/"$APP_KEY".pid
bundle exec rails server -p "$RAILS_PORT" -b '0.0.0.0' --pid /tmp/"$APP_KEY".pid
