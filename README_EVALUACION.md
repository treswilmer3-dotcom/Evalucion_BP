# DevOps Microservice - Evaluación

## 🎯 **Objetivo del Ejercicio**
Desplegar un microservicio REST con autenticación en AWS usando Docker y Terraform.

## ✅ **Requisitos Cumplidos**

### **Core Requirements**
- [x] REST endpoint `/DevOps` con método POST
- [x] Autenticación con API Key (`X-Parse-REST-API-Key`)
- [x] Autenticación con JWT (`X-JWT-KWY`)
- [x] Respuesta de error para métodos no-POST
- [x] Despliegue con contenedores Docker
- [x] Load balancer con mínimo 2 nodos

### **Despliegue AWS**
- [x] Infraestructura como código (Terraform)
- [x] Instancia EC2 funcionando
- [x] Docker Hub integration
- [x] Configuración de red y seguridad

## 🚀 **Despliegue Actual**

### **URLs de Acceso**
- **Load Balancer**: `http://3.237.195.29/health`
- **API 1**: `http://3.237.195.29:8001/health`
- **API 2**: `http://3.237.195.29:8002/health`

### **Arquitectura**
```
Internet → AWS EC2 (t3.micro) → Docker Compose
                                   ├── API 1 (puerto 8001)
                                   ├── API 2 (puerto 8002)
                                   └── Nginx Load Balancer (puerto 80)
```

## 🔧 **Configuración de Despliegue**

### **Tecnologías Utilizadas**
- **Infraestructura**: AWS EC2 + Terraform
- **Contenerización**: Docker + Docker Compose
- **Orquestación**: Nginx Load Balancer
- **Registry**: Docker Hub
- **Arquitectura**: x86_64

### **Variables de Entorno**
- `API_KEY`: 2f5ae96c-b558-4c7b-a590-a501ae1c3f6c
- `JWT_SECRET`: LOCAL_DEV_SECRET
- `DOCKER_IMAGE`: wilinvestiga/devops-microservice:B1

## 🧪 **Pruebas del Endpoint**

### **Request**
```bash
curl -X POST http://3.237.195.29/DevOps \
  -H "Content-Type: application/json" \
  -H "X-Parse-REST-API-Key: 2f5ae96c-b558-4c7b-a590-a501ae1c3f6c" \
  -H "X-JWT-KWY: [JWT_TOKEN]" \
  -d '{"to":"test@example.com","message":"Hello World"}'
```

### **Response Esperado**
```json
{
  "message": "Hello World sent to test@example.com"
}
```

## 📁 **Estructura del Proyecto**

```
Evalucion_BP/
├── app/                    # Código del microservicio
│   ├── main.py            # FastAPI application
│   ├── models.py          # Pydantic models
│   ├── service.py         # Lógica de negocio
│   └── security.py        # Autenticación
├── Dockerfile             # Definición del contenedor
├── docker-compose.yml     # Orquestación local
├── requirements.txt       # Dependencias Python
└── README.md            # Esta documentación
```

## 🎯 **Estado Actual**
✅ **Microservicio desplegado y funcionando en AWS**
✅ **Load balancer distribuyendo tráfico correctamente**
✅ **Autenticación API Key y JWT implementada**
✅ **Contenerización con Docker Hub completada**
✅ **Infraestructura optimizada (1 EC2 vs múltiples instancias)**

---
**🚀 Proyecto listo para evaluación**
