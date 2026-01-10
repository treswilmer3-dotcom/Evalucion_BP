terraform {
  required_version = ">= 1.0"
  
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

module "devops_app" {
  source = "../../modules/kubernetes"

  app_name      = "devops-microservice"
  environment   = "production"
  docker_image = "ghcr.io/your-username/devops-microservice:latest"
  replica_count = 3
  port          = 8000
  api_key       = var.api_key
  jwt_secret    = var.jwt_secret
  domain        = "prod.your-domain.com"
}
