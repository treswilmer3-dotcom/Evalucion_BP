variable "api_key" {
  description = "API Key for authentication"
  type        = string
  sensitive   = true
  default     = "2f5ae96c-b558-4c7b-a590-a501ae1c3f6c"
}

variable "jwt_secret" {
  description = "JWT Secret"
  type        = string
  sensitive   = true
  default     = "LOCAL_DEV_SECRET"
}
