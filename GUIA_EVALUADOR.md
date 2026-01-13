# 🚀 GUÍA RÁPIDA PARA EL EVALUADOR

## ⚡ **OPCIÓN 1: DESPLIEGUE AUTOMÁTICO (RECOMENDADO)**

### **🔑 Paso 1: Configurar Credenciales AWS**
```bash
# Instalar AWS CLI (si no está instalado)
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Configurar credenciales AWS
aws configure
# AWS Access Key ID: [SU_ACCESS_KEY]
# AWS Secret Access Key: [SU_SECRET_KEY]
# Default region name: us-east-1
# Default output format: json
```

### **🚀 Paso 2: Ejecutar Despliegue Automático**
```bash
# Un solo comando y listo
curl -sSL https://raw.githubusercontent.com/treswilmer3-dotcom/Evalucion_BP/master/deploy.sh | bash
```

### **✅ Resultado Esperado**
- 🌐 Load Balancer: `http://[IP_PÚBLICA]/health`
- 🔗 API 1: `http://[IP_PÚBLICA]:8001/health`
- 🔗 API 2: `http://[IP_PÚBLICA]:8002/health`
- 🎯 Endpoint DevOps: `http://[IP_PÚBLICA]/DevOps`

---

## 🔧 **OPCIÓN 2: DESPLIEGUE MANUAL PASO A PASO**

### **📋 Paso 1: Prerrequisitos**
- AWS CLI configurado
- Terraform instalado
- Git instalado

### **📋 Paso 2: Clonar y Desplegar**
```bash
# Clonar repositorio
git clone https://github.com/treswilmer3-dotcom/Evalucion_BP.git
cd Evalucion_BP

# Ejecutar script de despliegue
chmod +x deploy.sh
./deploy.sh
```

---

## 🧪 **PRUEBA DEL ENDPOINT DevOps**

### **📋 Método 1: Generar JWT y Probar**
```bash
# Conectarse a la instancia para obtener JWT
ssh -i [SU_CLAVE.pem] ec2-user@[IP_PÚBLICA]

# Generar JWT
pip3 install PyJWT
python3 -c "import jwt; print(jwt.encode({'user': 'test'}, 'LOCAL_DEV_SECRET', algorithm='HS256'))"

# Probar endpoint
TOKEN="[JWT_GENERADO]"
curl -X POST http://localhost/DevOps \
  -H "Content-Type: application/json" \
  -H "X-Parse-REST-API-Key: 2f5ae96c-b558-4c7b-a590-a501ae1c3f6c" \
  -H "X-JWT-KWY: $TOKEN" \
  -d '{"to":"test@example.com","message":"Hello World"}'
```

### **📋 Método 2: Prueba Rápida de Health**
```bash
# Verificar que todo esté funcionando
curl http://[IP_PÚBLICA]/health
curl http://[IP_PÚBLICA]:8001/health
curl http://[IP_PÚBLICA]:8002/health
```

---

## 🔐 **OPCIONES DE SEGURIDAD**

### **✅ Recomendación: Credenciales Temporales**
Para mayor seguridad, pueden crear un usuario IAM temporal:

1. **Ir a AWS Console → IAM → Users**
2. **Crear usuario**: `evaluador-temporal`
3. **Permisos**: 
   - `AmazonEC2FullAccess`
   - `AmazonVPCFullAccess`
4. **Generar claves** y usarlas en `aws configure`

### **🔄 Limpieza Post-Evaluación**
```bash
# Para eliminar todo (opcional)
cd Evalucion_BP/terraform/environments/aws
terraform destroy -auto-approve
```

---

## 📧 **SOPORTE TÉCNICO**

### **🆘 Si hay problemas:**
1. **Verificar credenciales AWS**: `aws sts get-caller-identity`
2. **Verificar instalación**: `terraform --version`, `aws --version`
3. **Revisar logs**: En la instancia EC2 con `docker-compose logs`

### **📞 Contacto**
- **Repositorio**: https://github.com/treswilmer3-dotcom/Evalucion_BP
- **Documentación**: README_EVALUACION.md

---

## ⏱️ **TIEMPO ESTIMADO**

- **Despliegue automático**: 5-10 minutos
- **Pruebas**: 2-3 minutos
- **Total**: ~15 minutos

---

**🎯 ¡El sistema está diseñado para máxima simplicidad y reproducibilidad!**
