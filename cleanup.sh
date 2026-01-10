#!/bin/bash
# cleanup.sh - Limpieza completa del entorno
set -e

echo "🧹 Limpiando entorno completamente..."

# Función para verificar si Docker está corriendo
check_docker() {
    if ! command -v docker &> /dev/null; then
        echo "⚠️ Docker no está instalado o no está corriendo"
        return 1
    fi
    
    if ! docker info &> /dev/null; then
        echo "⚠️ Docker daemon no está corriendo"
        return 1
    fi
    
    return 0
}

# 1. Detener todos los contenedores
if check_docker; then
    echo "🛑 Deteniendo todos los contenedores..."
    docker stop $(docker ps -aq) 2>/dev/null || true
    
    # 2. Eliminar todos los contenedores
    echo "🗑️ Eliminando todos los contenedores..."
    docker rm $(docker ps -aq) 2>/dev/null || true
    
    # 3. Eliminar todas las imágenes
    echo "🖼️ Eliminando todas las imágenes..."
    docker rmi $(docker images -q) 2>/dev/null || true
    
    # 4. Eliminar volúmenes no utilizados
    echo "📦 Eliminando volúmenes no utilizados..."
    docker volume prune -f 2>/dev/null || true
    
    # 5. Eliminar redes no utilizadas
    echo "🌐 Eliminando redes no utilizadas..."
    docker network prune -f 2>/dev/null || true
    
    # 6. Limpieza completa del sistema Docker
    echo "🧹 Limpieza completa del sistema Docker..."
    docker system prune -af 2>/dev/null || true
else
    echo "⚠️ Omitiendo limpieza de Docker (no disponible)"
fi

# 7. Eliminar carpetas del proyecto
echo "📁 Eliminando carpetas del proyecto..."
cd /root
if [ -d "devops-microservice" ]; then
    rm -rf devops-microservice
    echo "✅ Carpeta devops-microservice eliminada"
fi

# 8. Limpiar archivos temporales
echo "🗂️ Limpiando archivos temporales..."
rm -f /root/*.log 2>/dev/null || true
rm -f /root/*.json 2>/dev/null || true
rm -f /root/*.md 2>/dev/null || true

# 9. Limpiar caché de pip si existe
if [ -d "/root/.cache/pip" ]; then
    rm -rf /root/.cache/pip
    echo "✅ Caché de pip eliminado"
fi

echo ""
echo "✅ Entorno limpiado completamente!"
echo "🔄 El sistema está listo para una instalación limpia desde Git"
