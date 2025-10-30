# Imagen base PHP 8.3 con Alpine
FROM php:8.3-fpm-alpine

# Instalar dependencias del sistema
RUN apk add --no-cache \
    bash git zip unzip curl nodejs npm \
    libpng-dev libjpeg-turbo-dev freetype-dev \
    oniguruma-dev libxml2-dev icu-dev mysql-client \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath gd intl

# Instalar Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Crear directorio de trabajo
WORKDIR /var/www/html

# Copiar archivos necesarios para instalar dependencias
COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader

# Copiar archivos del frontend y construir los assets
COPY package*.json ./
RUN npm install && npm run build

# Copiar el resto del proyecto (incluye public/, resources/, etc.)
COPY . .

# Dar permisos correctos
RUN chown -R www-data:www-data storage bootstrap/cache public

# Cachear configuraciones de Laravel
RUN php artisan config:cache && php artisan route:cache && php artisan view:cache

# Exponer el puerto dinámico de Render
EXPOSE 10000

# Ejecutar migraciones y servir Laravel desde /public
CMD php artisan migrate --force && php -S 0.0.0.0:${PORT:-10000} -t public
