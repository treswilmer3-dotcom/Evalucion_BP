resource "docker_image" "app_image" {
  name         = var.docker_image
  keep_locally = false
}

resource "docker_network" "app_network" {
  name = "${var.app_name}-${var.environment}-network"
}

resource "docker_container" "api_containers" {
  count = var.replica_count
  
  name  = "${var.app_name}-${var.environment}-${count.index}"
  image = docker_image.app_image.image_id
  
  ports {
    internal = var.port
    external = var.port + count.index
  }
  
  networks_advanced {
    name = docker_network.app_network.name
  }
  
  env = [
    "API_KEY=${var.api_key}",
    "JWT_SECRET=${var.jwt_secret}",
    "ENVIRONMENT=${var.environment}"
  ]
  
  restart = "unless-stopped"
}

resource "docker_container" "nginx_lb" {
  name  = "${var.app_name}-${var.environment}-nginx"
  image = "nginx:alpine"
  
  ports {
    internal = 80
    external = 80
  }
  
  networks_advanced {
    name = docker_network.app_network.name
  }
  
  volumes {
    volume_name    = docker_volume.nginx_config.name
    container_path = "/etc/nginx/nginx.conf"
    read_only      = true
  }
  
  depends_on = [
    docker_container.api_containers
  ]
  
  restart = "unless-stopped"
}

resource "docker_volume" "nginx_config" {
  name = "${var.app_name}-${var.environment}-nginx-config"
  
  content = templatefile("${path.module}/nginx.conf.tftpl", {
    upstream_servers = [
      for container in docker_container.api_containers :
      "${container.name}:${var.port}"
    ]
  })
}
