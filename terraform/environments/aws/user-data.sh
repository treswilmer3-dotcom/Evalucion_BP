#!/bin/bash
# User data for single EC2 instance with Docker Compose

# Update system
yum update -y

# Install Docker
yum install -y docker git

# Start Docker
systemctl start docker
systemctl enable docker

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Clone repository
git clone https://github.com/treswilmer3-dotcom/Evalucion_BP.git /home/ec2-user/app
cd /home/ec2-user/app

# Create docker-compose.yml for this setup
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  api1:
    image: ${docker_hub_username}/devops-microservice:${docker_image_tag}
    container_name: api1
    ports:
      - "8001:8000"
    environment:
      - API_KEY=2f5ae96c-b558-4c7b-a590-a501ae1c3f6c
      - JWT_SECRET=LOCAL_DEV_SECRET
    restart: unless-stopped

  api2:
    image: ${docker_hub_username}/devops-microservice:${docker_image_tag}
    container_name: api2
    ports:
      - "8002:8000"
    environment:
      - API_KEY=2f5ae96c-b558-4c7b-a590-a501ae1c3f6c
      - JWT_SECRET=LOCAL_DEV_SECRET
    restart: unless-stopped

  nginx:
    image: nginx:alpine
    container_name: nginx
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      - api1
      - api2
    restart: unless-stopped
EOF

# Create nginx.conf
cat > nginx.conf << 'NGINX_EOF'
events {
    worker_connections 1024;
}

http {
    upstream api_servers {
        server api1:8000;
        server api2:8000;
    }

    server {
        listen 80;
        server_name _;

        location / {
            proxy_pass http://api_servers;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
NGINX_EOF

# Start services with Docker Compose
/usr/local/bin/docker-compose up -d

echo "✅ Docker Compose setup completed!"
echo "🌐 API 1: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8001/health"
echo "🌐 API 2: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8002/health"
echo "🌐 Load Balancer: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)/health"
