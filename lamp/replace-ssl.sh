#!/bin/bash

# Update packages and install other tools
apt update
apt install -y certbot python3-certbot-apache

# Obtaining the domain name of the server
read -p "Enter your domain name (eg example.com): " DOMAIN

# Configure Apache to handle domain name
bash -c "cat > /etc/apache2/sites-available/default-ssl.conf <<EOF
<VirtualHost *:80>
    ServerAdmin admin@$DOMAIN
    ServerName $DOMAIN
    DocumentRoot /var/www/html

    <Directory /var/www/html>
        Options Indexes FollowSymLinks MultiViews
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF"

# Enabling site configuration
a2ensite default-ssl.conf
systemctl reload apache2

# Using Certbot to get an SSL certificate
certbot --apache -d $DOMAIN

echo "SSL certificate configured and Apache restarted."

# Adding a cron job for certificate renewal
(crontab -l ; echo "0 0 1 * * /usr/bin/certbot renew --quiet --no-self-upgrade && systemctl reload apache2") | crontab -