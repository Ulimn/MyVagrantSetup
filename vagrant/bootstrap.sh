#!/bin/bash

echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" > /etc/apt/sources.list.d/pgdg.list

apt-get update -y
apt-get install wget curl apache2 php5 php5-cli php5-curl php5-common php5-pgsql php5-gd php5-imagick php5-geoip php5-sqlite php5-xmlrpc git postgresql-9.4 -y --force-yes

if ! [ -L /var/www ]; then
    rm -rf /var/www
    ln -fs /vagrant /var/www
fi

su postgres -c 'createuser -s develop; createuser -s vagrant'

# Install composer
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/

# Install fuelPHP
curl get.fuelphp.com/oil | sh

# Create default virtual host
echo "<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www

        <Directory />
                Options FollowSymLinks
                AllowOverride All
        </Directory>
        <Directory /var/www/>
                Options Indexes FollowSymLinks MultiViews
                AllowOverride All
                Order allow,deny
                allow from all
        </Directory>

        ErrorLog \${APACHE_LOG_DIR}/error.log

        LogLevel warn
        CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
" > /etc/apache2/sites-available/default

a2enmod rewrite
service apache2 restart