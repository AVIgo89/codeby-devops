#!/bin/bash
set -e

DOMAIN=${1:-example}
DOMAIN_FULL="$DOMAIN.local"

echo "=== Setting up client ==="
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

apt-get install -y curl ca-certificates openssl dnsutils iputils-ping net-tools

SERVER_IP=$(getent hosts server | awk '{print $1}')
if [ -z "$SERVER_IP" ]; then
    SERVER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' server 2>/dev/null || echo "172.17.0.2")
fi

echo "Server IP: $SERVER_IP"

echo "$SERVER_IP $DOMAIN_FULL www.$DOMAIN_FULL" >> /etc/hosts

mkdir -p /usr/local/share/ca-certificates/$DOMAIN_FULL

echo "Getting certificate from server..."

echo | openssl s_client -connect server:443 -servername $DOMAIN_FULL 2>/dev/null | \
    openssl x509 -outform PEM > /usr/local/share/ca-certificates/$DOMAIN_FULL/$DOMAIN_FULL.crt || true

if [ ! -f /usr/local/share/ca-certificates/$DOMAIN_FULL/$DOMAIN_FULL.crt ]; then
    curl -k https://server -o /tmp/server.crt 2>/dev/null || true
    if [ -f /tmp/server.crt ]; then
        openssl x509 -in /tmp/server.crt -outform PEM > /usr/local/share/ca-certificates/$DOMAIN_FULL/$DOMAIN_FULL.crt 2>/dev/null || true
    fi
fi

if [ -f /usr/local/share/ca-certificates/$DOMAIN_FULL/$DOMAIN_FULL.crt ]; then
    update-ca-certificates --fresh
    echo "Certificate added to trusted store"
else
    echo "Warning: Certificate file not found"
fi

cat > /test_ssl.sh <<'EOF'
#!/bin/bash
DOMAIN="example.local"
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "========================================="
echo "        SSL CONFIGURATION TEST"
echo "========================================="

echo -e "\n${YELLOW}1. DNS Resolution${NC}"
if grep -q "$DOMAIN" /etc/hosts; then
    echo -e "${GREEN}OK${NC} - $DOMAIN in /etc/hosts"
else
    echo -e "${RED}FAIL${NC} - $DOMAIN not in /etc/hosts"
fi

echo -e "\n${YELLOW}2. HTTP to HTTPS Redirect${NC}"
CODE=$(curl -s -o /dev/null -w "%{http_code}" http://$DOMAIN 2>/dev/null)
if [ "$CODE" = "301" ] || [ "$CODE" = "302" ]; then
    echo -e "${GREEN}OK${NC} - HTTP redirects to HTTPS (code $CODE)"
else
    echo -e "${RED}FAIL${NC} - HTTP does not redirect (code $CODE)"
fi

echo -e "\n${YELLOW}3. HTTPS Access${NC}"
CODE=$(curl -s -o /dev/null -w "%{http_code}" https://$DOMAIN 2>/dev/null)
if [ "$CODE" = "200" ]; then
    echo -e "${GREEN}OK${NC} - HTTPS accessible (code $CODE)"
else
    echo -e "${RED}FAIL${NC} - HTTPS not accessible (code $CODE)"
fi

echo -e "\n${YELLOW}4. SSL Certificate Trust${NC}"
if echo | openssl s_client -connect $DOMAIN:443 -servername $DOMAIN 2>&1 | grep -q "verify return:1"; then
    echo -e "${GREEN}OK${NC} - Certificate is trusted"
else
    echo -e "${RED}FAIL${NC} - Certificate is NOT trusted"
fi

echo -e "\n${YELLOW}5. www to non-www Redirect${NC}"
LOCATION=$(curl -s -I http://www.$DOMAIN 2>/dev/null | grep -i "^Location:" | awk '{print $2}')
if echo "$LOCATION" | grep -q "https://$DOMAIN"; then
    echo -e "${GREEN}OK${NC} - www redirects to non-www"
else
    echo -e "${RED}FAIL${NC} - www does not redirect"
fi

echo -e "\n${YELLOW}6. Security Headers${NC}"
HEADERS=$(curl -s -I https://$DOMAIN 2>/dev/null)
for HEADER in "Strict-Transport-Security" "X-Content-Type-Options" "X-Frame-Options"; do
    if echo "$HEADERS" | grep -q "$HEADER"; then
        echo -e "${GREEN}OK${NC} - $HEADER present"
    else
        echo -e "${RED}FAIL${NC} - $HEADER missing"
    fi
done

echo -e "\n========================================="
echo "           TEST COMPLETE"
echo "========================================="
EOF

chmod +x /test_ssl.sh

echo "=== Client setup complete ==="
echo "Run '/test_ssl.sh' to test"
