variable "app_name" {
  description = "Name of the application"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "docker_image" {
  description = "Docker image to deploy"
  type        = string
}

variable "replica_count" {
  description = "Number of replicas"
  type        = number
  default     = 2
}

variable "port" {
  description = "Application port"
  type        = number
  default     = 8000
}

variable "api_key" {
  description = "API Key for authentication"
  type        = string
  sensitive   = true
}

variable "jwt_secret" {
  description = "JWT Secret"
  type        = string
  sensitive   = true
}

variable "domain" {
  description = "Domain for the application"
  type        = string
  default     = "localhost"
}
