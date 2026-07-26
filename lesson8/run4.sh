#!/bin/bash

echo "Cleaning up old containers..."
docker rm -f server client 2>/dev/null || true

HTTP_PORT=8082
HTTPS_PORT=8445

echo "Using ports: HTTP=$HTTP_PORT, HTTPS=$HTTPS_PORT"

echo "Starting server..."
docker run -d --name server --hostname server --privileged \
  -p $HTTP_PORT:80 -p $HTTPS_PORT:443 \
  ubuntu:20.04 /bin/bash -c "while true; do sleep 3600; done"

sleep 3

echo "Copying scripts to server..."
docker cp provision_server.sh server:/provision_server.sh

echo "Configuring server..."
docker exec server bash -c "chmod +x /provision_server.sh && /provision_server.sh example"

SERVER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' server)
echo "Server IP: $SERVER_IP"

echo "Starting client..."
docker run -d --name client --hostname client --privileged \
  --add-host "server:$SERVER_IP" \
  ubuntu:20.04 /bin/bash -c "while true; do sleep 3600; done"

sleep 3

echo "Copying scripts to client..."
docker cp provision_client.sh client:/provision_client.sh

echo "Configuring client..."
docker exec client bash -c "chmod +x /provision_client.sh && /provision_client.sh example"

echo "Containers running:"
docker ps

echo "========================================="
echo "Testing from host..."
echo "-----------------------------------------"
echo "HTTP test (should redirect to HTTPS):"
curl -I http://localhost:$HTTP_PORT 2>/dev/null | head -3

echo ""
echo "HTTPS test:"
curl -k https://localhost:$HTTPS_PORT 2>/dev/null | head -10

echo "========================================="
echo "Setup complete!"
echo "HTTP: http://localhost:$HTTP_PORT"
echo "HTTPS: https://localhost:$HTTPS_PORT"
echo ""
echo "Connect to client:"
echo "  docker exec -it client bash"
echo ""
echo "Connect to server:"
echo "  docker exec -it server bash"
echo ""
echo "Inside client run:"
echo "  /test_ssl.sh"
echo "========================================="
