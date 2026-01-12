# User data for Load Balancer instance
#!/bin/bash
yum update -y
yum install -y docker

# Start Docker
systemctl start docker
systemctl enable docker

# Create nginx.conf
cat > /home/ec2-user/nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    upstream api_servers {
        server ${join(" ", api_servers)}:8000;
    }

    server {
        listen 80;
        server_name _;

        location /health {
            proxy_pass http://api_servers/health;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        location /DevOps {
            proxy_pass http://api_servers/DevOps;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
EOF

# Run Nginx container
docker run -d \
  --name nginx \
  -p 80:80 \
  -v /home/ec2-user/nginx.conf:/etc/nginx/nginx.conf:ro \
  nginx:alpine

echo "Load Balancer instance configured"
EOF
