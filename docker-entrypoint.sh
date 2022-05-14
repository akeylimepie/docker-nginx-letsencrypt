#!/usr/bin/env bash

DOMAINS=$(echo "$DOMAINS" | tr -s ' ')
USER_VHOST=/vhost.conf
NGINX_VHOST=/etc/nginx/conf.d/vhost.conf

if [ -z "$DOMAINS" ]; then
  echo "Empty env var DOMAINS"
  exit 1
fi

if [ ! -f "$USER_VHOST" ]; then
  echo "Mount your virtual host config to /vhost.conf"
  exit 2
fi

cp $USER_VHOST $NGINX_VHOST

sed -i -r -e "s/%DOMAINS%/$DOMAINS/g" $NGINX_VHOST

IFS=' '
read -ra list <<<"$DOMAINS"

ACME_DOMAIN_OPTION=""

for i in "${!list[@]}"; do
  if [[ $i == 0 ]]; then
    ACME_DOMAIN_OPTION+="-d ${list[$i]}"
  else
    ACME_DOMAIN_OPTION+=" -d ${list[$i]} --challenge-alias ${list[0]}"
  fi

  ACME_DOMAIN_OPTION+=" --dns dns_cf"
done

echo "Issue the cert: $DOMAINS with options $ACME_DOMAIN_OPTION"

/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt

/root/.acme.sh/acme.sh --issue \
  $ACME_DOMAIN_OPTION \
  --renew-hook "nginx -s reload"

/root/.acme.sh/acme.sh --install-cert $ACME_DOMAIN_OPTION \
  --fullchain-file /etc/nginx/ssl/app/fullchain.pem \
  --cert-file /etc/nginx/ssl/app/cert.pem \
  --key-file /etc/nginx/ssl/app/key.pem

openssl req -x509 -newkey rsa:4096 -nodes -days 365 \
  -subj "/C=CA/ST=QC/O=Company Inc/CN=example.com" \
  -out /etc/nginx/ssl/default/cert.pem \
  -keyout /etc/nginx/ssl/default/key.pem

echo "Start cron"
crond

echo "Start nginx"
nginx -g "daemon off;"
