output "service_url" {
  description = "URL of the deployed service"
  value       = "http://${var.domain}/DevOps"
}

output "loadbalancer_ip" {
  description = "IP of the load balancer"
  value       = kubernetes_service.devops_service.status.0.0.load_balancer.0.0.ingress.0.ip
}

output "namespace" {
  description = "Kubernetes namespace"
  value       = kubernetes_namespace.devops_namespace.metadata[0].name
}
