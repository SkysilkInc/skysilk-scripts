#!/bin/bash

# Update packages and install other tools
apt update
apt install -y certbot python3-certbot-apache

# Obtaining the domain name of the server
read -p "Enter your domain name (eg example.com): " DOMAIN

# Configure Apache to handle domain name
bash -c "cat > /etc/apache2/sites-available/wordpress.conf <<EOF
<VirtualHost *:80>
    ServerAdmin admin@$DOMAIN
    ServerName $DOMAIN
    DocumentRoot /var/www/wordpress

    <Directory /var/www/wordpress>
        Options Indexes FollowSymLinks MultiViews
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF"

# Enabling site configuration
a2ensite wordpress.conf
systemctl reload apache2

# Using Certbot to get an SSL certificate
certbot --apache -d $DOMAIN

echo "SSL certificate configured and Apache restarted. Go to WordPress admin panel to change URLs to HTTPS."

