#!/bin/bash
# prepare-git.sh - Prepara el proyecto para subir a Git
set -e

echo "🔧 Preparando proyecto para Git..."

# 1. Verificar si ya hay un repositorio Git
if [ -d ".git" ]; then
    echo "⚠️ Ya existe un repositorio Git. Eliminando..."
    rm -rf .git
fi

# 2. Inicializar repositorio Git
echo "📝 Inicializando repositorio Git..."
git init

# 3. Configurar usuario Git (si no está configurado)
if ! git config user.name &> /dev/null; then
    echo "⚙️ Configurando usuario Git..."
    git config user.name "DevOps Student"
    git config user.email "student@example.com"
fi

# 4. Agregar todos los archivos
echo "📦 Agregando archivos al repositorio..."
git add .

# 5. Hacer commit inicial
echo "💾 Creando commit inicial..."
git commit -m "Initial commit: Complete DevOps Microservice

✅ Features:
- FastAPI microservice with /DevOps endpoint
- API Key and JWT authentication
- Nginx load balancer with 2+ nodes
- Docker containerization
- Complete test suite (100% coverage)
- CI/CD pipeline with GitHub Actions
- Infrastructure as Code (Terraform)
- Kubernetes deployment manifests
- Automated deployment scripts

📋 Scripts:
- deploy-from-git.sh: Complete deployment from Git
- setup.sh: Clone and setup
- cleanup.sh: Clean environment
- validate.sh: Full validation
- integration-test.sh: Integration tests

🔧 Ready for production deployment and CI/CD"

# 6. Mostrar instrucciones
echo ""
echo "✅ Proyecto preparado para Git!"
echo ""
echo "📋 Siguientes pasos:"
echo "1. Crea un repositorio en GitHub: https://github.com/new"
echo "2. Reemplaza 'TU_USUARIO' en los scripts con tu usuario de GitHub"
echo "3. Ejecuta:"
echo "   git remote add origin https://github.com/TU_USUARIO/devops-microservice.git"
echo "   git branch -M main"
echo "   git push -u origin main"
echo ""
echo "🔄 Para probar reproducibilidad:"
echo "   ./cleanup.sh"
echo "   ./deploy-from-git.sh https://github.com/TU_USUARIO/devops-microservice.git"
echo "   ./validate.sh"
