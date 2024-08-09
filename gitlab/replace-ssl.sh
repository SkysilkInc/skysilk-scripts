#!/bin/bash

# Update packages and install other tools
apt update
apt-get install -y certbot

# Obtaining the domain name of the server
read -p "Enter your domain name (eg example.com): " DOMAIN


# Variables
CERT_DIR="/etc/letsencrypt/live"
GITLAB_CONFIG="/etc/gitlab/gitlab.rb"

# Obtain Let's Encrypt SSL certificate
certbot certonly --standalone -d $DOMAIN

# Update GitLab configuration
CERT_FILE="$CERT_DIR/$DOMAIN/fullchain.pem"
KEY_FILE="$CERT_DIR/$DOMAIN/privkey.pem"

sed -i "/^external_url/c\external_url \"https://$DOMAIN\"" $GITLAB_CONFIG
sed -i "/^nginx\['ssl_certificate'\]/c\nginx['ssl_certificate'] = \"$CERT_FILE\"" $GITLAB_CONFIG
sed -i "/^nginx\['ssl_certificate_key'\]/c\nginx['ssl_certificate_key'] = \"$KEY_FILE\"" $GITLAB_CONFIG

# Reconfigure GitLab
gitlab-ctl reconfigure

echo "Let's Encrypt SSL certificate has been obtained and GitLab configuration updated."


# Adding a cron job for certificate renewal
(crontab -l ; echo "0 0 1 * * /usr/bin/certbot renew --quiet --no-self-upgrade && gitlab-ctl restart nginx") | crontab -