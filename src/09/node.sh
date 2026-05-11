#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/lib/metrics.sh"
source "$SCRIPT_DIR/lib/server.sh"

if ! command -v nginx &>/dev/null; then
    echo "Installing nginx..."
    sudo apt update && sudo apt install nginx -y
fi

sudo mkdir -p /var/www/html
sudo touch /var/www/html/metrics
sudo chmod 644 /var/www/html/metrics

sudo tee /etc/nginx/sites-available/metrics > /dev/null << 'NGINX'
server {
    listen 9101;
    location /metrics {
        root /var/www/html;
        default_type text/plain;
    }
}
NGINX

sudo ln -sf /etc/nginx/sites-available/metrics \
            /etc/nginx/sites-enabled/metrics

sudo nginx -t && sudo systemctl reload nginx

echo "Metrics available at http://localhost:9101/metrics"
echo "Starting metrics collection. Press Ctrl+C to stop."

run_loop