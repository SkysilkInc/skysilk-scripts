#!/bin/bash

# Update packages and install other tools
apt update
apt install -y certbot python3-certbot-nginx

# Obtaining the domain name of the server
read -p "Enter your domain name (eg example.com): " DOMAIN

# Configure Nginx to handle domain name
bash -c "cat > /etc/nginx/sites-available/$DOMAIN <<EOF
server {
    listen 80;
    server_name $DOMAIN;

    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF"

# Enabling site configuration
ln -s /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/
systemctl reload nginx

# Using Certbot to get an SSL certificate
certbot --nginx -d $DOMAIN

sed -i '/location \/ {/,/}/d' /etc/nginx/sites-available/$DOMAIN
systemctl reload nginx

echo "SSL certificate configured and Nginx restarted."

# Adding a cron job for certificate renewal
(crontab -l ; echo "0 0 1 * * /usr/bin/certbot renew --quiet --no-self-upgrade && systemctl reload nginx") | crontab -

echo "Cron job for certificate renewal added."