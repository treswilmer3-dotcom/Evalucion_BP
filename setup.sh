#!/bin/bash
# setup.sh - Reconstrucción automática desde Git
set -e

echo "🚀 Reconstruyendo proyecto desde Git..."

# Verificar si git está instalado
if ! command -v git &> /dev/null; then
    echo "❌ Git no está instalado. Por favor instálalo primero."
    exit 1
fi

# Verificar si docker está instalado
if ! command -v docker &> /dev/null; then
    echo "❌ Docker no está instalado. Por favor instálalo primero."
    exit 1
fi

# Verificar si docker-compose está disponible
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose no está disponible. Por favor instálalo primero."
    exit 1
fi

# 1. Clonar repositorio (reemplazar URL con tu repo real)
REPO_URL=${1:-"https://github.com/TU_USUARIO/devops-microservice.git"}

if [ -d "devops-microservice" ]; then
    echo "📁 Eliminando directorio existente..."
    rm -rf devops-microservice
fi

echo "📥 Clonando repositorio: $REPO_URL"
git clone "$REPO_URL"
cd devops-microservice

# 2. Crear entorno virtual
echo "🐍 Creando entorno virtual..."
python3 -m venv venv
source venv/bin/activate

# 3. Instalar dependencias
echo "📦 Instalando dependencias..."
pip install --upgrade pip
pip install -r requirements.txt

# 4. Construir y levantar servicios
echo "🐳 Construyendo y levantando servicios..."
docker compose down 2>/dev/null || true
docker compose up -d --build

# 5. Esperar que servicios estén listos
echo "⏳ Esperando que servicios estén listos..."
sleep 15

# 6. Verificar que todo funciona
echo "🔍 Verificando servicios..."
docker compose ps

# 7. Verificar que el servicio esté disponible
echo "🌐 Verificando disponibilidad del servicio..."
for i in {1..30}; do
    if curl -f http://localhost/health > /dev/null 2>&1; then
        echo "✅ Servicio está disponible en http://localhost/health"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "❌ El servicio no está disponible después de 60 segundos"
        exit 1
    fi
    sleep 2
done

echo ""
echo "🎉 Reconstrucción completada exitosamente!"
echo "🌐 API disponible en: http://localhost/DevOps"
echo "🏥 Health check en: http://localhost/health"
echo ""
echo "📋 Para ejecutar pruebas de integración:"
echo "   ./integration-test.sh"
echo ""
echo "📋 Para validación completa:"
echo "   ./validate.sh"
