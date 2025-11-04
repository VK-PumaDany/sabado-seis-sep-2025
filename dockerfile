# Imagen base de PHP 8.3 con Alpine
FROM php:8.3-fpm-alpine

# Instalar dependencias del sistema y extensiones necesarias
RUN apk add --no-cache \
    bash \
    git \
    zip \
    unzip \
    curl \
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

# Crear directorio de la app
WORKDIR /var/www/html

# Copiar composer.json y composer.lock primero
COPY composer.json composer.lock ./

# Instalar dependencias de PHP
RUN composer install --no-dev --optimize-autoloader --no-scripts --no-interaction

# Copiar el resto de archivos de Laravel
COPY . .

# Crear .env si no existe (basado en .env.example)
RUN if [ ! -f .env ]; then cp .env.example .env; fi

# Generar application key si no existe
RUN php artisan key:generate --ansi

# Ejecutar scripts de composer ahora que todos los archivos están presentes
RUN composer dump-autoload --optimize --no-scripts

# Permisos para el almacenamiento y caché
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache && \
    chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Exponer el puerto
EXPOSE 10000

# Script de inicio
COPY docker/start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]