#!/bin/bash

# DevOps Microservice Deployment Script

set -e

ENVIRONMENT=${1:-staging}
IMAGE_TAG=${2:-latest}

echo "🚀 Deploying DevOps Microservice to $ENVIRONMENT environment..."

# Function to deploy to staging
deploy_staging() {
    echo "📦 Deploying to staging environment..."
    
    # Build and push Docker image
    docker build -t devops-microservice:$IMAGE_TAG .
    docker tag devops-microservice:$IMAGE_TAG devops-microservice:latest
    
    # Update docker-compose and restart
    docker-compose down
    docker-compose up -d
    
    # Wait for services to be ready
    echo "⏳ Waiting for services to be ready..."
    sleep 10
    
    # Health check
    echo "🔍 Performing health check..."
    if curl -f http://localhost/health > /dev/null 2>&1; then
        echo "✅ Staging deployment successful!"
        echo "🌐 Service available at: http://localhost/DevOps"
    else
        echo "❌ Health check failed!"
        exit 1
    fi
}

# Function to deploy to production
deploy_production() {
    echo "🏭 Deploying to production environment..."
    
    # Check if kubectl is available
    if ! command -v kubectl &> /dev/null; then
        echo "❌ kubectl not found. Please install kubectl for production deployment."
        exit 1
    fi
    
    # Apply Kubernetes manifests
    echo "📋 Applying Kubernetes manifests..."
    kubectl apply -f k8s/
    
    # Wait for rollout
    echo "⏳ Waiting for deployment rollout..."
    kubectl rollout status deployment/devops-microservice
    
    # Get service URL
    SERVICE_URL=$(kubectl get service devops-microservice-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "localhost")
    
    echo "✅ Production deployment successful!"
    echo "🌐 Service available at: http://$SERVICE_URL/DevOps"
}

# Function to run tests
run_tests() {
    echo "🧪 Running tests..."
    
    # Activate virtual environment
    if [ -d "venv" ]; then
        source venv/bin/activate
    fi
    
    # Run tests with coverage
    pytest tests/ -v --cov=app --cov-report=term
    
    if [ $? -eq 0 ]; then
        echo "✅ All tests passed!"
    else
        echo "❌ Tests failed!"
        exit 1
    fi
}

# Function to perform security checks
security_checks() {
    echo "🔒 Running security checks..."
    
    # Activate virtual environment
    if [ -d "venv" ]; then
        source venv/bin/activate
    fi
    
    # Run Bandit security scan
    bandit -r app/ -f json -o bandit-report.json
    
    # Run Safety check
    safety check --json --output safety-report.json
    
    echo "✅ Security checks completed!"
    echo "📄 Reports generated: bandit-report.json, safety-report.json"
}

# Function to validate deployment
validate_deployment() {
    echo "🔍 Validating deployment..."
    
    # Generate JWT token
    JWT=$(python3 -c "from app.security import generate_jwt; print(generate_jwt())" 2>/dev/null || echo "")
    
    if [ -z "$JWT" ]; then
        echo "❌ Failed to generate JWT token"
        exit 1
    fi
    
    # Test API endpoint
    RESPONSE=$(curl -s -X POST http://localhost/DevOps \
        -H "X-Parse-REST-API-Key: 2f5ae96c-b558-4c7b-a590-a501ae1c3f6c" \
        -H "X-JWT-KWY: $JWT" \
        -H "Content-Type: application/json" \
        -d '{"message": "This is a test", "to": "Juan Perez", "from": "Rita Asturia", "timeToLifeSec": 45}')
    
    if echo "$RESPONSE" | grep -q "Hello Juan Perez"; then
        echo "✅ API validation successful!"
        echo "📝 Response: $RESPONSE"
    else
        echo "❌ API validation failed!"
        echo "📝 Response: $RESPONSE"
        exit 1
    fi
}

# Main deployment flow
main() {
    case $ENVIRONMENT in
        "staging")
            run_tests
            security_checks
            deploy_staging
            validate_deployment
            ;;
        "production")
            run_tests
            security_checks
            deploy_production
            ;;
        "test")
            run_tests
            security_checks
            ;;
        *)
            echo "❌ Invalid environment: $ENVIRONMENT"
            echo "Usage: $0 [staging|production|test] [image-tag]"
            exit 1
            ;;
    esac
}

# Execute main function
main
