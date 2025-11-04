# Imagen base PHP 8.3 con FPM y Alpine
FROM php:8.3-fpm-alpine

# Instalar dependencias del sistema y extensiones PHP
RUN apk add --no-cache \
    bash \
    git \
    zip \
    unzip \
    curl \
    nginx \
    supervisor \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    oniguruma-dev \
    libxml2-dev \
    icu-dev \
    mysql-client \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath gd intl

# Instalar Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Directorio de trabajo
WORKDIR /var/www/html

# Copiar archivos del proyecto
COPY . .

# Instalar dependencias PHP
RUN composer install --no-dev --optimize-autoloader

# Copiar configuración de Nginx
COPY ./nginx.conf /etc/nginx/nginx.conf

# Permisos
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Exponer puerto dinámico de Render
EXPOSE 10000

# Configurar Supervisor para ejecutar Nginx + PHP-FPM
RUN mkdir -p /etc/supervisor/conf.d
COPY <<EOF /etc/supervisor/conf.d/supervisord.conf
[supervisord]
nodaemon=true

[program:php-fpm]
command=docker-php-entrypoint php-fpm
autostart=true
autorestart=true

[program:nginx]
command=nginx -g 'daemon off;'
autostart=true
autorestart=true
EOF

# Comando final
CMD php artisan migrate --force && supervisord -c /etc/supervisor/conf.d/supervisord.conf
