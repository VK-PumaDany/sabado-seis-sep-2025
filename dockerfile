# Imagen base ligera
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
    libzip-dev \
    oniguruma-dev \
    && docker-php-ext-install pdo_mysql mbstring zip exif pcntl bcmath gd

# Crear directorio de trabajo
WORKDIR /var/www/html

# Copiar composer desde otra imagen temporal
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copiar los archivos del proyecto
COPY . .

# Instalar dependencias PHP (sin dev para producción)
RUN composer install --no-dev --optimize-autoloader

# Dar permisos correctos
RUN chown -R www-data:www-data storage bootstrap/cache

# Exponer el puerto 8080 (Render usará este puerto)
EXPOSE 8080

# Comando de inicio
CMD php artisan serve --host=0.0.0.0 --port=8080