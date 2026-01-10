terraform {
  required_version = ">= 1.0"
  
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

module "devops_app" {
  source = "../../modules/docker"

  app_name      = "devops-microservice"
  environment   = "staging"
  docker_image = "devops-microservice:latest"
  replica_count = 2
  port          = 8000
  api_key       = var.api_key
  jwt_secret    = var.jwt_secret
  domain        = "localhost"
}
