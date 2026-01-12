# User data for API instances
#!/bin/bash
yum update -y
yum install -y docker git

# Start Docker
systemctl start docker
systemctl enable docker

# Clone repository
git clone https://github.com/treswilmer3-dotcom/Evalucion_BP.git /home/ec2-user/app
cd /home/ec2-user/app

# Build Docker image
docker build -t devops-microservice .

# Run API container
docker run -d \
  --name devops-api \
  -p 8000:8000 \
  -e API_KEY=2f5ae96c-b558-4c7b-a590-a501ae1c3f6c \
  -e JWT_SECRET=LOCAL_DEV_SECRET \
  devops-microservice

echo "API instance ${node_number} configured"
EOF
