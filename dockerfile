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

# Copiar composer files primero
COPY composer.json composer.lock ./

# Copiar .env temporal para el build
COPY .env.docker .env

# Instalar dependencias sin scripts
RUN composer install --no-dev --no-scripts --no-autoloader

# Copiar el resto de archivos
COPY . .

# Generar autoloader y ejecutar scripts
RUN composer dump-autoload --optimize

# Generar APP_KEY si no existe
RUN php artisan key:generate --force || true

# Permisos para el almacenamiento y caché
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Exponer el puerto que Render asigna dinámicamente
EXPOSE 10000

# Crear script de inicio que usa las variables de Render
RUN echo '#!/bin/sh' > /start.sh && \
    echo 'cd /var/www/html' >> /start.sh && \
    echo '' >> /start.sh && \
    echo '# Configurar APP_URL y ASSET_URL desde RENDER_EXTERNAL_URL' >> /start.sh && \
    echo 'if [ -n "$RENDER_EXTERNAL_URL" ]; then' >> /start.sh && \
    echo '  export APP_URL="$RENDER_EXTERNAL_URL"' >> /start.sh && \
    echo '  export ASSET_URL="$RENDER_EXTERNAL_URL"' >> /start.sh && \
    echo 'fi' >> /start.sh && \
    echo '' >> /start.sh && \
    echo '# Limpiar y cachear configuración' >> /start.sh && \
    echo 'php artisan config:clear' >> /start.sh && \
    echo 'php artisan cache:clear' >> /start.sh && \
    echo 'php artisan config:cache' >> /start.sh && \
    echo 'php artisan route:cache' >> /start.sh && \
    echo 'php artisan view:cache' >> /start.sh && \
    echo '' >> /start.sh && \
    echo '# Ejecutar migraciones' >> /start.sh && \
    echo 'php artisan migrate --force' >> /start.sh && \
    echo '' >> /start.sh && \
    echo '# Iniciar servidor' >> /start.sh && \
    echo 'exec php artisan serve --host=0.0.0.0 --port=${PORT:-10000}' >> /start.sh && \
    chmod +x /start.sh

# Comando para correr Laravel en Render
CMD ["/start.sh"]