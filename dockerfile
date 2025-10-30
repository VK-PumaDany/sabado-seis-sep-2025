# Imagen base de PHP 8.3 con Alpine
FROM php:8.3-fpm-alpine

# Instalar dependencias del sistema y extensiones necesarias
RUN apk add --no-cache \
    bash \
    git \
    zip \
    unzip \
    curl \
    nodejs \
    npm \
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

# Copiar archivos de Laravel
COPY . .

# Instalar dependencias de PHP
RUN composer install --no-dev --optimize-autoloader

# 🔹 Instalar dependencias del frontend y construir los assets
# (esto soluciona el problema de que los estilos no carguen)
RUN if [ -f package.json ]; then \
      npm install && npm run build; \
    fi

# 🔹 Dar permisos correctos para el almacenamiento y caché
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# 🔹 Limpiar y optimizar la configuración de Laravel
RUN php artisan config:cache && php artisan route:cache && php artisan view:cache

# Exponer el puerto que Render asigna dinámicamente
EXPOSE 10000

# 🔹 Ejecutar migraciones y servir desde la carpeta pública
CMD php artisan migrate --force && php -S 0.0.0.0:${PORT:-10000} -t public
