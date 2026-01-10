#!/bin/bash
# deploy-from-git.sh - Script completo de despliegue desde Git
set -e

echo "🚀 Despliegue completo desde Git - DevOps Microservice"
echo "=================================================="

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir mensajes coloreados
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️ $1${NC}"
}

# Verificar dependencias del sistema
check_dependencies() {
    print_info "Verificando dependencias del sistema..."
    
    local missing_deps=()
    
    if ! command -v git &> /dev/null; then
        missing_deps+=("git")
    fi
    
    if ! command -v docker &> /dev/null; then
        missing_deps+=("docker")
    fi
    
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        missing_deps+=("docker-compose")
    fi
    
    if ! command -v python3 &> /dev/null; then
        missing_deps+=("python3")
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_error "Faltan las siguientes dependencias: ${missing_deps[*]}"
        print_info "Por favor instala las dependencias faltantes y ejecuta nuevamente."
        exit 1
    fi
    
    print_status "Todas las dependencias están instaladas"
}

# Función principal de despliegue
deploy_project() {
    local repo_url=${1:-"https://github.com/TU_USUARIO/devops-microservice.git"}
    
    print_info "URL del repositorio: $repo_url"
    
    # 1. Limpiar entorno anterior
    print_info "Limpiando entorno anterior..."
    if [ -f "cleanup.sh" ]; then
        ./cleanup.sh
    else
        print_warning "Script cleanup.sh no encontrado, limpiando manualmente..."
        rm -rf devops-microservice 2>/dev/null || true
    fi
    
    # 2. Clonar repositorio
    print_info "Clonando repositorio..."
    git clone "$repo_url"
    cd devops-microservice
    
    # 3. Hacer scripts ejecutables
    print_info "Configurando permisos de scripts..."
    chmod +x *.sh
    
    # 4. Crear entorno virtual
    print_info "Creando entorno virtual..."
    python3 -m venv venv
    source venv/bin/activate
    
    # 5. Instalar dependencias
    print_info "Instalando dependencias Python..."
    pip install --upgrade pip
    pip install -r requirements.txt
    
    # 6. Construir y levantar servicios
    print_info "Construyendo y levantando servicios Docker..."
    docker compose down 2>/dev/null || true
    docker compose up -d --build
    
    # 7. Esperar servicios
    print_info "Esperando que servicios estén listos..."
    sleep 20
    
    # 8. Verificar estado
    print_info "Verificando estado de los servicios..."
    docker compose ps
    
    # 9. Verificar disponibilidad
    print_info "Verificando disponibilidad del servicio..."
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if curl -f http://localhost/health > /dev/null 2>&1; then
            print_status "Servicio disponible en http://localhost/health"
            break
        fi
        
        if [ $attempt -eq $max_attempts ]; then
            print_error "El servicio no está disponible después de $((max_attempts * 2)) segundos"
            print_info "Verificando logs de contenedores:"
            docker compose logs --tail=20
            exit 1
        fi
        
        print_info "Intento $attempt/$max_attempts - esperando 2 segundos..."
        sleep 2
        ((attempt++))
    done
    
    # 10. Ejecutar validación
    print_info "Ejecutando validación completa..."
    if [ -f "validate.sh" ]; then
        ./validate.sh
    else
        print_warning "Script validate.sh no encontrado, ejecutando validación básica..."
        
        # Validación básica
        JWT=$(python3 -c "from app.security import generate_jwt; print(generate_jwt())")
        RESPONSE=$(curl -s -X POST http://localhost/DevOps \
            -H "X-Parse-REST-API-Key: 2f5ae96c-b558-4c7b-a590-a501ae1c3f6c" \
            -H "X-JWT-KWY: $JWT" \
            -H "Content-Type: application/json" \
            -d '{"message": "Test from scratch", "to": "User", "from": "System", "timeToLifeSec": 45}')
        
        if echo "$RESPONSE" | grep -q "Hello User"; then
            print_status "Validación básica exitosa"
        else
            print_error "Validación básica falló"
            exit 1
        fi
    fi
}

# Función de ayuda
show_help() {
    echo "Uso: $0 [OPCIÓN] [REPO_URL]"
    echo ""
    echo "OPCIONES:"
    echo "  -h, --help     Muestra esta ayuda"
    echo "  -c, --check    Solo verifica dependencias"
    echo "  -r, --repo     URL del repositorio (default: https://github.com/TU_USUARIO/devops-microservice.git)"
    echo ""
    echo "EJEMPLOS:"
    echo "  $0                                    # Usa URL por defecto"
    echo "  $0 https://github.com/user/my-repo.git  # Usa URL personalizada"
    echo "  $0 --check                           # Solo verifica dependencias"
}

# Main
case "${1:-}" in
    -h|--help)
        show_help
        exit 0
        ;;
    -c|--check)
        check_dependencies
        exit 0
        ;;
    -r|--repo)
        if [ -z "${2:-}" ]; then
            print_error "Se requiere URL del repositorio"
            show_help
            exit 1
        fi
        check_dependencies
        deploy_project "$2"
        ;;
    "")
        check_dependencies
        deploy_project
        ;;
    *)
        if [[ "$1" == http* ]]; then
            check_dependencies
            deploy_project "$1"
        else
            print_error "Opción no reconocida: $1"
            show_help
            exit 1
        fi
        ;;
esac

print_status "🎉 Despliegue completado exitosamente!"
echo ""
echo "🌐 Servicios disponibles:"
echo "   • API: http://localhost/DevOps"
echo "   • Health: http://localhost/health"
echo ""
echo "📋 Comandos útiles:"
echo "   • Ver logs: docker compose logs -f"
echo "   • Detener: docker compose down"
echo "   • Reiniciar: docker compose restart"
echo "   • Tests: ./integration-test.sh"
