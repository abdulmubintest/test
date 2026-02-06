#!/usr/bin/env bash
set -euo pipefail

echo "Building containers (frontend, backend, db, redis, internal_proxy)..."
docker-compose build

echo "Starting containers in the background..."
docker-compose up -d

echo
echo "Waiting for services to be ready..."
echo "  Waiting for database..."
max_attempts=30
attempt=0
while [ $attempt -lt $max_attempts ]; do
    if docker exec blog_postgres pg_isready -U bloguser -d blogdb >/dev/null 2>&1; then
        echo "  ✓ Database is ready"
        break
    fi
    attempt=$((attempt + 1))
    sleep 1
done

if [ $attempt -eq $max_attempts ]; then
    echo "  ⚠ Database not ready after $max_attempts seconds, but continuing..."
fi

echo "  Waiting for backend to be ready..."
attempt=0
while [ $attempt -lt $max_attempts ]; do
    if docker exec blog_backend python -c "import django; print('OK')" 2>/dev/null | grep -q "OK"; then
        # Check if the API responds (curl is optional)
        if command -v curl >/dev/null 2>&1; then
            if curl -s http://localhost:8000/api/posts/ >/dev/null 2>&1; then
                echo "  ✓ Backend is ready"
                break
            fi
        else
            # If curl not available, just check Django is importable
            echo "  ✓ Backend is ready"
            break
        fi
    fi
    attempt=$((attempt + 1))
    sleep 1
done

if [ $attempt -eq $max_attempts ]; then
    echo "  ⚠ Backend not fully ready after $max_attempts seconds"
    echo "     Check logs with: docker logs blog_backend"
fi

echo
echo "Setting up nginx reverse proxy for kybernode.com..."
echo "=================================================="

# Check if nginx is installed
if ! command -v nginx >/dev/null 2>&1; then
    echo "Installing nginx..."
    if command -v apt-get >/dev/null 2>&1; then
        apt-get update && apt-get install -y nginx
    elif command -v yum >/dev/null 2>&1; then
        yum install -y nginx
    elif command -v dnf >/dev/null 2>&1; then
        dnf install -y nginx
    else
        echo "Error: Could not detect package manager to install nginx"
        exit 1
    fi
else
    echo "nginx is already installed"
fi

# Create nginx configuration
NGINX_CONF="/etc/nginx/sites-available/kybernode.com"
NGINX_ENABLED="/etc/nginx/sites-enabled/kybernode.com"

echo "Creating nginx configuration for kybernode.com..."

cat > "$NGINX_CONF" << 'EOF'
server {
    listen 80;
    server_name kybernode.com www.kybernode.com;

    # Frontend - serve React app
    location / {
        proxy_pass http://127.0.0.1:80;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Backend API - proxy to Django
    location /api/ {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Health check endpoint
    location /health {
        return 200 'OK';
        add_header Content-Type text/plain;
    }
}
EOF

# Enable the site
ln -sf "$NGINX_CONF" "$NGINX_ENABLED"

# Remove default site if exists
rm -f /etc/nginx/sites-enabled/default

# Test nginx configuration
echo "Testing nginx configuration..."
nginx -t

# Restart nginx
echo "Restarting nginx..."
if command -v systemctl >/dev/null 2>&1; then
    systemctl restart nginx
    systemctl enable nginx
else
    # For systems without systemctl
    nginx -s reload || nginx
fi

echo
echo "✓ Nginx reverse proxy configured successfully!"
echo
echo "All services started."
echo "Frontend: http://localhost:80 (listening on port 80)"
echo "Backend API: http://localhost:8000"
echo
echo "Nginx reverse proxy is now active for kybernode.com:"
echo "  - http://kybernode.com -> frontend (React app)"
echo "  - http://kybernode.com/api/ -> backend (Django API)"
echo
echo "To run tests: ./test.sh"
echo
echo "IMPORTANT: Make sure your DNS A record for kybernode.com points to this server's IP address."
