#!/bin/sh

cd /app/backend

if ! php artisan migrate --force; then
    echo "============================================"
    echo "ERROR: Migrations could not complete. Check the error above."
    echo "Ensure DATABASE_URL is set."
    echo "============================================"
fi

php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear

# Ensure storage directories exist with proper permissions
mkdir -p /app/backend/storage/app/public
mkdir -p /app/backend/storage/framework/cache
mkdir -p /app/backend/storage/framework/sessions
mkdir -p /app/backend/storage/framework/views
mkdir -p /app/backend/storage/logs

chown -R www-data:www-data /app/backend
chmod -R 775 /app/backend/storage /app/backend/bootstrap/cache

# Create storage link (remove existing if present)
rm -f /app/backend/public/storage
php artisan storage:link

# Configure nginx to use Railway's PORT if set, otherwise use 80
PORT=${PORT:-80}
sed -i "s/listen 80;/listen ${PORT};/g" /etc/nginx/nginx.conf
sed -i "s/listen \[::\]:80;/listen [::]:${PORT};/g" /etc/nginx/nginx.conf

exec /usr/bin/supervisord -c /etc/supervisord.conf
