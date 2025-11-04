#!/bin/bash
set -e

echo "🚀 Iniciando aplicación Laravel..."

# Función para esperar a que la base de datos esté lista
wait_for_db() {
    echo "⏳ Esperando a que la base de datos esté lista..."
    
    max_attempts=30
    attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if php artisan db:show >/dev/null 2>&1; then
            echo "✅ Base de datos conectada!"
            return 0
        fi
        
        echo "   Intento $attempt/$max_attempts - Base de datos no disponible, esperando..."
        sleep 2
        attempt=$((attempt + 1))
    done
    
    echo "❌ No se pudo conectar a la base de datos después de $max_attempts intentos"
    return 1
}

# Esperar a que la base de datos esté lista
if wait_for_db; then
    # Ejecutar migraciones
    echo "📦 Ejecutando migraciones..."
    php artisan migrate --force
else
    echo "⚠️  Iniciando sin migraciones - la base de datos no está disponible"
fi

# Optimizar Laravel para producción
echo "⚡ Optimizando Laravel..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Iniciar servidor Laravel
echo "🌐 Iniciando servidor en puerto ${PORT:-10000}..."
php artisan serve --host=0.0.0.0 --port=${PORT:-10000}