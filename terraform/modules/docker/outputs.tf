output "container_names" {
  description = "Names of the API containers"
  value       = docker_container.api_containers[*].name
}

output "nginx_container_name" {
  description = "Name of the nginx container"
  value       = docker_container.nginx_lb.name
}

output "service_url" {
  description = "URL of the service"
  value       = "http://${var.domain}/DevOps"
}
