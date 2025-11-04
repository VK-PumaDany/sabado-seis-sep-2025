#!/bin/bash
set -e

echo "🚀 Iniciando aplicación Laravel..."

# Ejecutar migraciones
echo "📦 Ejecutando migraciones..."
php artisan migrate --force

# Optimizar Laravel para producción
echo "⚡ Optimizando Laravel..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Iniciar servidor Laravel
echo "🌐 Iniciando servidor en puerto ${PORT:-10000}..."
php artisan serve --host=0.0.0.0 --port=${PORT:-10000}