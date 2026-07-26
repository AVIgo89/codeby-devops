#!/bin/bash
set -e

DOMAIN=${1:-example}
DOMAIN_FULL="$DOMAIN.local"

echo "=== Setting up server ==="
echo "Domain: $DOMAIN_FULL"

pkill -f apt-get 2>/dev/null || true
sleep 2

rm -f /var/lib/dpkg/lock-frontend /var/lib/dpkg/lock /var/cache/apt/archives/lock 2>/dev/null || true
dpkg --configure -a 2>/dev/null || true

apt-get update
apt-get install -y openssh-server sudo

mkdir -p /var/run/sshd
echo 'root:root' | chpasswd
echo 'vagrant:vagrant' | chpasswd
useradd -m -s /bin/bash vagrant 2>/dev/null || true

mkdir -p /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh

cat > /home/vagrant/.ssh/authorized_keys <<'EOF'
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key
EOF

chmod 600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh

sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
service ssh start

a2enmod ssl
a2enmod rewrite
a2enmod headers

mkdir -p /var/www/$DOMAIN_FULL/public_html
mkdir -p /var/www/$DOMAIN_FULL/logs
mkdir -p /var/log/apache2/$DOMAIN_FULL

chown -R www-data:www-data /var/www/$DOMAIN_FULL
chmod 755 /var/www/$DOMAIN_FULL/public_html

SERVER_IP=$(hostname -I | awk '{print $1}')

cat > /var/www/$DOMAIN_FULL/public_html/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>$DOMAIN_FULL</title>
    <style>
        body { font-family: Arial; max-width: 800px; margin: 50px auto; padding: 20px; }
        .success { color: green; font-weight: bold; }
        .info { background: #f0f0f0; padding: 15px; border-radius: 5px; }
    </style>
</head>
<body>
    <h1>Welcome to $DOMAIN_FULL</h1>
    <p class="success">HTTPS is working correctly!</p>
    <div class="info">
        <p><strong>Server:</strong> $(hostname)</p>
        <p><strong>IP:</strong> $SERVER_IP</p>
        <p><strong>Date:</strong> $(date)</p>
    </div>
</body>
</html>
EOF

mkdir -p /etc/ssl/$DOMAIN_FULL

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/$DOMAIN_FULL/private.key \
    -out /etc/ssl/$DOMAIN_FULL/certificate.crt \
    -subj "/C=RU/ST=Moscow/L=Moscow/O=IT/CN=$DOMAIN_FULL" \
    -addext "subjectAltName=DNS:$DOMAIN_FULL,DNS:www.$DOMAIN_FULL,IP:$SERVER_IP"

chmod 600 /etc/ssl/$DOMAIN_FULL/private.key
chmod 644 /etc/ssl/$DOMAIN_FULL/certificate.crt

cat > /etc/apache2/sites-available/$DOMAIN_FULL.conf <<EOF
<VirtualHost *:80>
    ServerName $DOMAIN_FULL
    ServerAlias www.$DOMAIN_FULL

    ErrorLog /var/log/apache2/$DOMAIN_FULL/error.log
    CustomLog /var/log/apache2/$DOMAIN_FULL/access.log combined

    RewriteEngine On

    RewriteCond %{HTTP_HOST} ^www\.$DOMAIN_FULL$ [NC]
    RewriteRule ^(.*)$ http://$DOMAIN_FULL\$1 [R=301,L]

    RewriteCond %{HTTPS} off
    RewriteRule ^(.*)$ https://%{HTTP_HOST}\$1 [R=301,L]
</VirtualHost>
EOF

cat > /etc/apache2/sites-available/$DOMAIN_FULL-ssl.conf <<EOF
<VirtualHost *:443>
    ServerName $DOMAIN_FULL
    ServerAlias www.$DOMAIN_FULL
    DocumentRoot /var/www/$DOMAIN_FULL/public_html

    ErrorLog /var/log/apache2/$DOMAIN_FULL/error-ssl.log
    CustomLog /var/log/apache2/$DOMAIN_FULL/access-ssl.log combined

    SSLEngine on
    SSLCertificateFile /etc/ssl/$DOMAIN_FULL/certificate.crt
    SSLCertificateKeyFile /etc/ssl/$DOMAIN_FULL/private.key

    RewriteEngine On

    RewriteCond %{HTTP_HOST} ^www\.$DOMAIN_FULL$ [NC]
    RewriteRule ^(.*)$ https://$DOMAIN_FULL\$1 [R=301,L]

    Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains"
    Header always set X-Content-Type-Options "nosniff"
    Header always set X-Frame-Options "SAMEORIGIN"

    <Directory /var/www/$DOMAIN_FULL/public_html>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF

a2ensite $DOMAIN_FULL.conf
a2ensite $DOMAIN_FULL-ssl.conf
a2dissite 000-default.conf

echo "127.0.0.1 $DOMAIN_FULL www.$DOMAIN_FULL" >> /etc/hosts
echo "$SERVER_IP $DOMAIN_FULL www.$DOMAIN_FULL" >> /etc/hosts

service apache2 restart

echo "=== Server setup complete ==="
echo "Site: https://$DOMAIN_FULL"
echo "IP: $SERVER_IP"
