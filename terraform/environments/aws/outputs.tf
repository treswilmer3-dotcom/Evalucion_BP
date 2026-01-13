output "instance_public_ip" {
  description = "Public IP address of EC2 instance"
  value       = aws_instance.main.public_ip
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.main.id
}

output "load_balancer_url" {
  description = "URL of load balancer"
  value       = "http://${aws_instance.main.public_ip}"
}

output "api1_url" {
  description = "URL of API 1"
  value       = "http://${aws_instance.main.public_ip}:8001"
}

output "api2_url" {
  description = "URL of API 2"
  value       = "http://${aws_instance.main.public_ip}:8002"
}
