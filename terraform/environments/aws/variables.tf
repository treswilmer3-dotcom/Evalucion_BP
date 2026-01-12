variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "devops-microservice"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "api_instance_count" {
  description = "Number of API instances"
  type        = number
  default     = 2
}

variable "key_name" {
  description = "EC2 Key Pair name"
  type        = string
  default     = "devops-key"
}

# Data source for availability zones
data "aws_availability_zones" "available" {
  state = "available"
}
