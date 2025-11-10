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
php artisan storage:link

chown -R www-data:www-data /app/backend
chmod -R 775 /app/backend/storage /app/backend/bootstrap/cache

# Configure nginx to use Railway's PORT if set, otherwise use 80
PORT=${PORT:-80}
sed -i "s/listen 80;/listen ${PORT};/g" /etc/nginx/nginx.conf
sed -i "s/listen \[::\]:80;/listen [::]:${PORT};/g" /etc/nginx/nginx.conf

exec /usr/bin/supervisord -c /etc/supervisord.conf
