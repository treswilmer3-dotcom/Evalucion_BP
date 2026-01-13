#!/bin/bash

# =============================================================================
# DevOps Microservice - Deploy Script
# =============================================================================
# Script para desplegar el microservicio desde cero en AWS
# =============================================================================

set -e  # Detener si hay errores

# Colores para salida
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir mensajes
print_step() {
    echo -e "${BLUE}🔧 Paso $1: $2${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# =============================================================================
# PASO 1: Verificar prerequisitos
# =============================================================================
print_step "1" "Verificando prerequisitos..."

# Verificar si AWS CLI está instalado
if ! command -v aws &> /dev/null; then
    print_error "AWS CLI no está instalado. Por favor instálalo primero."
    echo "Instrucciones: https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html"
    exit 1
fi

# Verificar si Terraform está instalado
if ! command -v terraform &> /dev/null; then
    print_error "Terraform no está instalado. Por favor instálalo primero."
    echo "Instrucciones: https://learn.hashicorp.com/tutorials/terraform/install-cli"
    exit 1
fi

# Verificar si Git está instalado
if ! command -v git &> /dev/null; then
    print_error "Git no está instalado. Por favor instálalo primero."
    exit 1
fi

# Verificar credenciales de AWS
if ! aws sts get-caller-identity &> /dev/null; then
    print_error "Credenciales de AWS no configuradas. Ejecuta 'aws configure' primero."
    exit 1
fi

print_success "Prerequisitos verificados"

# =============================================================================
# PASO 2: Clonar repositorio
# =============================================================================
print_step "2" "Clonando repositorio..."

# Si ya existe el directorio, eliminarlo
if [ -d "Evalucion_BP" ]; then
    print_warning "Eliminando directorio existente..."
    rm -rf Evalucion_BP
fi

# Clonar repositorio
git clone https://github.com/treswilmer3-dotcom/Evalucion_BP.git
cd Evalucion_BP

print_success "Repositorio clonado"

# =============================================================================
# PASO 3: Configurar Terraform
# =============================================================================
print_step "3" "Configurando Terraform..."

cd terraform/environments/aws

# Inicializar Terraform
terraform init

print_success "Terraform inicializado"

# =============================================================================
# PASO 4: Desplegar infraestructura
# =============================================================================
print_step "4" "Desplegando infraestructura en AWS..."

# Aplicar configuración de Terraform
terraform apply -auto-approve

# Obtener IP pública
INSTANCE_IP=$(terraform output -raw instance_public_ip)
API1_URL=$(terraform output -raw api1_url)
API2_URL=$(terraform output -raw api2_url)
LB_URL=$(terraform output -raw load_balancer_url)

print_success "Infraestructura desplegada"
echo -e "${GREEN}🌐 IP Pública: ${INSTANCE_IP}${NC}"
echo -e "${GREEN}🌐 Load Balancer: ${LB_URL}${NC}"

# =============================================================================
# PASO 5: Esperar y verificar despliegue
# =============================================================================
print_step "5" "Esperando inicialización de servicios..."

echo "⏳ Esperando 3 minutos para que los servicios se inicien..."
sleep 180

# Verificar que los servicios estén funcionando
print_step "6" "Verificando servicios..."

echo "🔍 Verificando Load Balancer..."
if curl -s --max-time 10 "${LB_URL}/health" | grep -q "ok"; then
    print_success "Load Balancer funcionando"
else
    print_error "Load Balancer no responde"
fi

echo "🔍 Verificando API 1..."
if curl -s --max-time 10 "${API1_URL}/health" | grep -q "ok"; then
    print_success "API 1 funcionando"
else
    print_error "API 1 no responde"
fi

echo "🔍 Verificando API 2..."
if curl -s --max-time 10 "${API2_URL}/health" | grep -q "ok"; then
    print_success "API 2 funcionando"
else
    print_error "API 2 no responde"
fi

# =============================================================================
# RESUMEN FINAL
# =============================================================================
echo ""
echo -e "${GREEN}🎉 ¡DESPLIEGUE COMPLETADO CON ÉXITO!${NC}"
echo ""
echo -e "${BLUE}📋 URLs de Acceso:${NC}"
echo -e "🔗 Load Balancer: ${LB_URL}"
echo -e "🔗 API 1: ${API1_URL}"
echo -e "🔗 API 2: ${API2_URL}"
echo -e "🔗 Endpoint DevOps: ${LB_URL}/DevOps"
echo ""
echo -e "${BLUE}🧪 Prueba del Endpoint:${NC}"
echo "curl -X POST ${LB_URL}/DevOps \\"
echo "  -H \"Content-Type: application/json\" \\"
echo "  -H \"X-Parse-REST-API-Key: 2f5ae96c-b558-4c7b-a590-a501ae1c3f6c\" \\"
echo "  -H \"X-JWT-KWY: [JWT_TOKEN]\" \\"
echo "  -d '{\"to\":\"test@example.com\",\"message\":\"Hello World\"}'"
echo ""
echo -e "${GREEN}✅ El microservicio está listo para evaluación${NC}"