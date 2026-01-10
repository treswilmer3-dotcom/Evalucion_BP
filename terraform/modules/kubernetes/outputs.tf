output "namespace" {
  description = "Kubernetes namespace"
  value       = kubernetes_namespace.devops_namespace.metadata[0].name
}

output "service_name" {
  description = "Kubernetes service name"
  value       = kubernetes_service.devops_service.metadata[0].name
}

output "deployment_name" {
  description = "Kubernetes deployment name"
  value       = kubernetes_deployment.app_deployment.metadata[0].name
}

output "service_url" {
  description = "URL of the service"
  value       = "http://${var.domain}/DevOps"
}
